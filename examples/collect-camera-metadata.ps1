param(
    [string]$Serial = "",
    [string]$OutDir = "artifacts\quest-camera-metadata",
    [string]$Adb = "adb",
    [switch]$IncludeBroker,
    [switch]$LaunchBroker,
    [switch]$GrantBrokerCameraPermissions,
    [string]$BrokerPackage = "",
    [string]$BrokerActivity = "",
    [int]$BrokerHostPort = 8765,
    [int]$BrokerDevicePort = 8765,
    [string[]]$BrokerEndpoints = @("/status", "/clock/now", "/clock/health")
)

$ErrorActionPreference = "Stop"

function Get-AdbArguments {
    param([string[]]$Arguments)
    if ([string]::IsNullOrWhiteSpace($Serial)) {
        return $Arguments
    }
    return @("-s", $Serial) + $Arguments
}

function Write-TextCapture {
    param(
        [string]$Path,
        [string]$Title,
        [string[]]$Arguments
    )
    $adbArgs = Get-AdbArguments -Arguments $Arguments
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# $Title")
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
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Write-HttpCapture {
    param(
        [string]$Path,
        [string]$Url
    )
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# GET $Url")
    try {
        $output = & curl.exe --silent --show-error --max-time 8 $Url 2>&1 | ForEach-Object { [string]$_ }
        foreach ($line in $output) {
            $lines.Add($line)
        }
        $lines.Add("# exitCode=$LASTEXITCODE")
    }
    catch {
        $lines.Add("# error=$($_.Exception.Message)")
    }
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-TextCapture -Path (Join-Path $OutDir "adb-devices.txt") -Title "ADB devices" -Arguments @("devices", "-l")
Write-TextCapture -Path (Join-Path $OutDir "device-properties.txt") -Title "Device properties" -Arguments @(
    "shell", "getprop"
)
Write-TextCapture -Path (Join-Path $OutDir "display-wm-size.txt") -Title "wm size" -Arguments @("shell", "wm", "size")
Write-TextCapture -Path (Join-Path $OutDir "display-wm-density.txt") -Title "wm density" -Arguments @("shell", "wm", "density")
Write-TextCapture -Path (Join-Path $OutDir "display-dumpsys.txt") -Title "dumpsys display" -Arguments @("shell", "dumpsys", "display")
Write-TextCapture -Path (Join-Path $OutDir "dumpsys-media-camera.txt") -Title "dumpsys media.camera" -Arguments @("shell", "dumpsys", "media.camera")
Write-TextCapture -Path (Join-Path $OutDir "cmd-media-camera-dump.txt") -Title "cmd media.camera dump" -Arguments @("shell", "cmd", "media.camera", "dump")

if ($IncludeBroker) {
    if ($GrantBrokerCameraPermissions) {
        if ([string]::IsNullOrWhiteSpace($BrokerPackage)) {
            throw "-GrantBrokerCameraPermissions requires -BrokerPackage."
        }
        Write-TextCapture -Path (Join-Path $OutDir "broker-grant-camera.txt") -Title "grant CAMERA" -Arguments @("shell", "pm", "grant", $BrokerPackage, "android.permission.CAMERA")
        Write-TextCapture -Path (Join-Path $OutDir "broker-grant-headset-camera.txt") -Title "grant HEADSET_CAMERA" -Arguments @("shell", "pm", "grant", $BrokerPackage, "horizonos.permission.HEADSET_CAMERA")
    }

    if ($LaunchBroker) {
        if ([string]::IsNullOrWhiteSpace($BrokerPackage) -or [string]::IsNullOrWhiteSpace($BrokerActivity)) {
            throw "-LaunchBroker requires -BrokerPackage and -BrokerActivity."
        }
        Write-TextCapture -Path (Join-Path $OutDir "broker-launch.txt") -Title "launch broker" -Arguments @("shell", "am", "start", "-n", "$BrokerPackage/$BrokerActivity")
        Start-Sleep -Seconds 3
    }

    Write-TextCapture -Path (Join-Path $OutDir "broker-adb-forward.txt") -Title "broker adb forward" -Arguments @("forward", "tcp:$BrokerHostPort", "tcp:$BrokerDevicePort")
    foreach ($endpoint in $BrokerEndpoints) {
        $safeName = ($endpoint.Trim("/") -replace "[^A-Za-z0-9_.-]", "_")
        if ([string]::IsNullOrWhiteSpace($safeName)) {
            $safeName = "root"
        }
        Write-HttpCapture -Path (Join-Path $OutDir "broker-$safeName.txt") -Url "http://127.0.0.1:$BrokerHostPort$endpoint"
    }
}

$manifest = [ordered]@{
    schemaVersion = "meta.quest.camera-metadata-collection.v1"
    createdAt = (Get-Date).ToString("o")
    serial = $Serial
    includeBroker = [bool]$IncludeBroker
    brokerHostPort = if ($IncludeBroker) { $BrokerHostPort } else { $null }
    brokerDevicePort = if ($IncludeBroker) { $BrokerDevicePort } else { $null }
    outDir = (Resolve-Path -LiteralPath $OutDir).Path
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir "metadata-manifest.json") -Encoding UTF8
Write-Host "Wrote metadata bundle to $OutDir"

