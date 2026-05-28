param(
    [string]$Serial = "",
    [Parameter(Mandatory = $true)]
    [string]$Apk,
    [Parameter(Mandatory = $true)]
    [string]$Package,
    [Parameter(Mandatory = $true)]
    [string]$Activity,
    [string]$OutDir = "artifacts\launch-smoke",
    [string]$Adb = "adb",
    [string[]]$ExtraGrant = @(),
    [int]$WaitSeconds = 10,
    [int]$FreshnessFrames = 2,
    [int]$FreshnessIntervalMs = 1000,
    [bool]$ClearLogcat = $true
)

$ErrorActionPreference = "Stop"

function Get-AdbArguments {
    param([string[]]$Arguments)
    if ([string]::IsNullOrWhiteSpace($Serial)) {
        return $Arguments
    }
    return @("-s", $Serial) + $Arguments
}

function Invoke-AdbText {
    param(
        [string[]]$Arguments,
        [string]$OutputPath
    )
    $adbArgs = Get-AdbArguments -Arguments $Arguments
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# adb $($adbArgs -join ' ')")
    try {
        $output = & $Adb @adbArgs 2>&1 | ForEach-Object { [string]$_ }
        foreach ($line in $output) {
            $lines.Add($line)
        }
        $lines.Add("# exitCode=$LASTEXITCODE")
    }
    catch {
        $lines.Add("# error=$($_.Exception.Message)")
    }
    Set-Content -LiteralPath $OutputPath -Value $lines -Encoding UTF8
}

function Invoke-AdbBinary {
    param(
        [string[]]$Arguments,
        [string]$OutputPath
    )
    $adbArgs = Get-AdbArguments -Arguments $Arguments
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Adb
    foreach ($arg in $adbArgs) {
        [void]$psi.ArgumentList.Add($arg)
    }
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($psi)
    $stream = [System.IO.File]::Create($OutputPath)
    try {
        $process.StandardOutput.BaseStream.CopyTo($stream)
    }
    finally {
        $stream.Dispose()
    }
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($stderr) {
        Set-Content -LiteralPath "$OutputPath.stderr.txt" -Value $stderr -Encoding UTF8
    }
    if ($process.ExitCode -ne 0) {
        throw "adb binary capture failed with exit code $($process.ExitCode); see $OutputPath.stderr.txt"
    }
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Invoke-AdbText -Arguments @("devices", "-l") -OutputPath (Join-Path $OutDir "adb-devices.txt")
Invoke-AdbText -Arguments @("install", "-r", "-d", "-g", $Apk) -OutputPath (Join-Path $OutDir "install.txt")

foreach ($permission in $ExtraGrant) {
    $safePermission = $permission -replace "[^A-Za-z0-9_.-]", "_"
    Invoke-AdbText -Arguments @("shell", "pm", "grant", $Package, $permission) -OutputPath (Join-Path $OutDir "grant-$safePermission.txt")
}

Invoke-AdbText -Arguments @("shell", "dumpsys", "window") -OutputPath (Join-Path $OutDir "foreground-before.txt")

if ($ClearLogcat) {
    Invoke-AdbText -Arguments @("logcat", "-c") -OutputPath (Join-Path $OutDir "logcat-clear.txt")
}

$startedAt = Get-Date
Invoke-AdbText -Arguments @("shell", "am", "start", "-n", "$Package/$Activity") -OutputPath (Join-Path $OutDir "launch.txt")
Start-Sleep -Seconds $WaitSeconds

Invoke-AdbText -Arguments @("shell", "dumpsys", "window") -OutputPath (Join-Path $OutDir "foreground-after.txt")
Invoke-AdbText -Arguments @("shell", "pidof", $Package) -OutputPath (Join-Path $OutDir "pidof.txt")
Invoke-AdbText -Arguments @("logcat", "-d", "-v", "threadtime") -OutputPath (Join-Path $OutDir "logcat.txt")
Invoke-AdbBinary -Arguments @("exec-out", "screencap", "-p") -OutputPath (Join-Path $OutDir "screenshot.png")

if ($FreshnessFrames -gt 1) {
    $freshnessDir = Join-Path $OutDir "freshness-frames"
    New-Item -ItemType Directory -Force -Path $freshnessDir | Out-Null
    $frames = @()
    for ($index = 0; $index -lt $FreshnessFrames; $index++) {
        $framePath = Join-Path $freshnessDir ("frame-{0:D2}.png" -f $index)
        Invoke-AdbBinary -Arguments @("exec-out", "screencap", "-p") -OutputPath $framePath
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $framePath).Hash
        $frames += [ordered]@{
            index = $index
            path = $framePath
            sha256 = $hash
            bytes = (Get-Item -LiteralPath $framePath).Length
        }
        if ($index -lt ($FreshnessFrames - 1) -and $FreshnessIntervalMs -gt 0) {
            Start-Sleep -Milliseconds $FreshnessIntervalMs
        }
    }
    $uniqueHashCount = @($frames | ForEach-Object { $_.sha256 } | Sort-Object -Unique).Count
    [ordered]@{
        schemaVersion = "meta.quest.screenshot-freshness.v1"
        frameCount = $FreshnessFrames
        intervalMs = $FreshnessIntervalMs
        uniqueSha256Count = $uniqueHashCount
        byteIdenticalFreezeSuspected = $uniqueHashCount -eq 1
        frames = $frames
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutDir "freshness-summary.json") -Encoding UTF8
}

[ordered]@{
    schemaVersion = "meta.quest.install-launch-watch.v1"
    startedAt = $startedAt.ToString("o")
    completedAt = (Get-Date).ToString("o")
    serial = $Serial
    apk = $Apk
    package = $Package
    activity = $Activity
    waitSeconds = $WaitSeconds
    extraGrant = $ExtraGrant
    outDir = (Resolve-Path -LiteralPath $OutDir).Path
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutDir "launch-summary.json") -Encoding UTF8

Write-Host "Wrote launch evidence to $OutDir"

