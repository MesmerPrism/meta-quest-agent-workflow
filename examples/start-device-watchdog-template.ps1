param(
    [string]$Serial = "",
    [Parameter(Mandatory = $true)]
    [string]$HelperJar,
    [Parameter(Mandatory = $true)]
    [string]$MainClass,
    [string]$Adb = "adb",
    [string]$DeviceJar = "/data/local/tmp/meta-quest-agent-helper.jar",
    [int]$StatusPort = 8765,
    [int]$HostPort = 8765,
    [switch]$DryRun,
    [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = "Stop"

function Get-AdbArguments {
    param([string[]]$Arguments)
    if ([string]::IsNullOrWhiteSpace($Serial)) {
        return $Arguments
    }
    return @("-s", $Serial) + $Arguments
}

function Invoke-OrPrint {
    param([string[]]$Arguments)
    $adbArgs = Get-AdbArguments -Arguments $Arguments
    Write-Host "adb $($adbArgs -join ' ')"
    if (-not $DryRun) {
        & $Adb @adbArgs
        if ($LASTEXITCODE -ne 0) {
            throw "adb command failed with exit code $LASTEXITCODE"
        }
    }
}

Invoke-OrPrint -Arguments @("push", $HelperJar, $DeviceJar)
Invoke-OrPrint -Arguments @("forward", "tcp:$HostPort", "tcp:$StatusPort")

$helperArgs = @(
    "--watchdog",
    "--status-port", $StatusPort.ToString()
) + $ExtraArgs

$remoteCommand = "CLASSPATH=$DeviceJar app_process /system/bin $MainClass $($helperArgs -join ' ')"
Invoke-OrPrint -Arguments @("shell", $remoteCommand)

Write-Host "If the helper exposes HTTP status, probe http://127.0.0.1:$HostPort/status"

