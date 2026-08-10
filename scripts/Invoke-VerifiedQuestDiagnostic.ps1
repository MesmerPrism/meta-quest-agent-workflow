param(
    [ValidateSet("Health", "Foreground", "LogcatClear", "Logcat", "Screenshot", "PerfettoVr")]
    [string]$Recipe = "Health",
    [string]$Serial = "",
    [string]$OutputDirectory = "",
    [string]$Package = "",
    [string]$Tag = "",
    [ValidateRange(1, 5000)]
    [int]$Lines = 1000,
    [ValidateRange(1000, 30000)]
    [int]$DurationMilliseconds = 5000,
    [ValidateRange(10, 120)]
    [int]$TimeoutSeconds = 60,
    [switch]$SelfTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PinnedPackage = "metavr@1.3.2"
$ExpectedVersion = "metavr 1.3.2.2.2"

function Get-RecipeId {
    param([string]$Name)
    switch ($Name) {
        "LogcatClear" { return "logcat-clear" }
        "PerfettoVr" { return "perfetto-vr" }
        default { return $Name.ToLowerInvariant() }
    }
}

function Get-RecipeArguments {
    param(
        [string]$Name,
        [string]$TargetSerial,
        [string]$OutRoot,
        [string]$TargetPackage,
        [string]$LogTag,
        [int]$LogLines,
        [int]$TraceDuration
    )

    switch ($Name) {
        "Health" { return @("device", "health-check", "--device", $TargetSerial, "--json") }
        "Foreground" { return @("app", "foreground", "--device", $TargetSerial, "--json") }
        "LogcatClear" { return @("log", "--device", $TargetSerial, "--clear", "--lines", "1", "--format", "plain") }
        "Logcat" {
            $arguments = @("log", "--device", $TargetSerial, "--lines", [string]$LogLines, "--format", "plain")
            if ($LogTag) { $arguments += @("--tag", $LogTag) }
            return $arguments
        }
        "Screenshot" {
            return @(
                "capture", "screenshot", "--device", $TargetSerial,
                "--method", "screencap", "--output", (Join-Path $OutRoot "screenshot.png"), "--json"
            )
        }
        "PerfettoVr" {
            $arguments = @(
                "perf", "capture", "--device", $TargetSerial, "--mode", "vr",
                "--duration", [string]$TraceDuration, "--output", (Join-Path $OutRoot "perfetto-vr"), "--json"
            )
            if ($TargetPackage) { $arguments += @("--app", $TargetPackage) }
            return $arguments
        }
    }
}

function Invoke-Bounded {
    param(
        [string]$Executable,
        [string[]]$Arguments,
        [int]$DeadlineSeconds,
        [hashtable]$Environment = @{}
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Executable
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $startInfo.ArgumentList.Add($argument) }
    foreach ($name in $Environment.Keys) {
        $startInfo.Environment[[string]$name] = [string]$Environment[$name]
    }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) { throw "Meta VR CLI provider did not start." }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($DeadlineSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "Meta VR CLI provider exceeded the bounded timeout."
        }
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            StandardOutput = $stdoutTask.GetAwaiter().GetResult()
            StandardError = $stderrTask.GetAwaiter().GetResult()
        }
    } finally {
        $process.Dispose()
    }
}

function Assert-SafeInputs {
    if ($Serial -cnotmatch "^[A-Za-z0-9._:-]{1,128}$") { throw "Serial is invalid." }
    if ($Package -and $Package -cnotmatch "^[A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z0-9_]+)+$") { throw "Package is invalid." }
    if ($Tag -and $Tag -cnotmatch "^[A-Za-z][A-Za-z0-9_.-]{0,63}$") { throw "Tag is invalid." }
}

if ($SelfTest) {
    $root = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) "verified-diagnostic-selftest"))
    $screenshot = (Get-RecipeArguments Screenshot QUEST123 $root "" "" 1000 5000) -join "|"
    $trace = (Get-RecipeArguments PerfettoVr QUEST123 $root "com.example.app" "" 1000 7000) -join "|"
    $log = (Get-RecipeArguments Logcat QUEST123 $root "" "RQApp" 321 5000) -join "|"
    if ($screenshot -cnotmatch "^capture\|screenshot\|--device\|QUEST123\|--method\|screencap\|--output\|") { throw "Screenshot vector drifted." }
    if ($trace -cnotmatch "perf\|capture\|--device\|QUEST123\|--mode\|vr\|--duration\|7000" -or $trace -cnotmatch "--app\|com.example.app$") { throw "Perfetto vector drifted." }
    if ($log -cne "log|--device|QUEST123|--lines|321|--format|plain|--tag|RQApp") { throw "Logcat vector drifted." }
    [ordered]@{
        schema = "rusty.quest.workflow.verified_diagnostic_self_test.v1"
        status = "passed"
        provider_package = $PinnedPackage
        recipes = @("health", "foreground", "logcat-clear", "logcat", "screenshot", "perfetto-vr")
    } | ConvertTo-Json -Depth 4
    exit 0
}

Assert-SafeInputs
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { throw "OutputDirectory is required." }
$outRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $outRoot) { throw "OutputDirectory must be a new run-owned directory." }
New-Item -ItemType Directory -Path $outRoot | Out-Null

$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$version = Invoke-Bounded -Executable $npx -Arguments @("-y", $PinnedPackage, "--version") -DeadlineSeconds 30
if ($version.ExitCode -ne 0 -or $version.StandardOutput.Trim() -cne $ExpectedVersion) {
    throw "Pinned Meta VR CLI version probe failed."
}
$arguments = Get-RecipeArguments $Recipe $Serial $outRoot $Package $Tag $Lines $DurationMilliseconds
$providerArguments = @("-y", $PinnedPackage) + $arguments
$execution = Invoke-Bounded `
    -Executable $npx `
    -Arguments $providerArguments `
    -DeadlineSeconds $TimeoutSeconds `
    -Environment @{ ANDROID_SERIAL = $Serial }
[System.IO.File]::WriteAllText(
    (Join-Path $outRoot "stdout.txt"),
    [string]$execution.StandardOutput,
    [System.Text.UTF8Encoding]::new($false))
if (-not [string]::IsNullOrWhiteSpace([string]$execution.StandardError)) {
    [System.IO.File]::WriteAllText(
        (Join-Path $outRoot "stderr.txt"),
        [string]$execution.StandardError,
        [System.Text.UTF8Encoding]::new($false))
}
if ($execution.ExitCode -ne 0) { throw "Pinned Meta VR CLI recipe failed with exit code $($execution.ExitCode)." }

$files = @(Get-ChildItem -LiteralPath $outRoot -File | Where-Object Name -ne "receipt.json" | Sort-Object Name | ForEach-Object {
    [ordered]@{
        name = $_.Name
        size_bytes = $_.Length
        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
    }
})
$receipt = [ordered]@{
    schema = "rusty.quest.workflow.verified_diagnostic_receipt.v1"
    status = "passed"
    recipe = Get-RecipeId $Recipe
    provider = "meta-vr-cli-pinned"
    provider_package = $PinnedPackage
    provider_cli_version = $ExpectedVersion
    serial = $Serial
    authority = if ($Recipe -in @("Health", "Foreground")) { "transport-observed" } else { "diagnostic-only" }
    files = $files
}
$receipt | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $outRoot "receipt.json") -Encoding utf8NoBOM
$receipt | ConvertTo-Json -Depth 8
