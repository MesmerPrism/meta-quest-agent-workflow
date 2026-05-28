param(
    [string]$Serial = "",
    [string]$OutDir = "artifacts\broker-status-probe",
    [string]$Adb = "adb",
    [int]$HostPort = 8765,
    [int]$DevicePort = 8765,
    [string[]]$Endpoints = @("/status", "/clock/now", "/clock/health")
)

$ErrorActionPreference = "Stop"

function Get-AdbArguments {
    param([string[]]$Arguments)
    if ([string]::IsNullOrWhiteSpace($Serial)) {
        return $Arguments
    }
    return @("-s", $Serial) + $Arguments
}

function Write-Text {
    param(
        [string]$Path,
        [string[]]$Lines
    )
    Set-Content -LiteralPath $Path -Value $Lines -Encoding UTF8
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$forwardArgs = Get-AdbArguments -Arguments @("forward", "tcp:$HostPort", "tcp:$DevicePort")
$forwardOutput = & $Adb @forwardArgs 2>&1 | ForEach-Object { [string]$_ }
Write-Text -Path (Join-Path $OutDir "adb-forward.txt") -Lines (@("# adb $($forwardArgs -join ' ')") + $forwardOutput + "# exitCode=$LASTEXITCODE")

foreach ($endpoint in $Endpoints) {
    $safeName = ($endpoint.Trim("/") -replace "[^A-Za-z0-9_.-]", "_")
    if ([string]::IsNullOrWhiteSpace($safeName)) {
        $safeName = "root"
    }
    $url = "http://127.0.0.1:$HostPort$endpoint"
    $output = & curl.exe --silent --show-error --max-time 8 $url 2>&1 | ForEach-Object { [string]$_ }
    Write-Text -Path (Join-Path $OutDir "$safeName.txt") -Lines (@("# GET $url") + $output + "# exitCode=$LASTEXITCODE")
}

[ordered]@{
    schemaVersion = "meta.quest.broker-status-probe.v1"
    createdAt = (Get-Date).ToString("o")
    serial = $Serial
    hostPort = $HostPort
    devicePort = $DevicePort
    endpoints = $Endpoints
    outDir = (Resolve-Path -LiteralPath $OutDir).Path
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir "probe-summary.json") -Encoding UTF8

Write-Host "Wrote broker probe evidence to $OutDir"

