param(
    [string]$RepoRoot = "",
    [switch]$VerifyProvider
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

function Get-TextSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
    $hash = [System.Security.Cryptography.SHA256]::HashData($bytes)
    return -join ($hash | ForEach-Object { $_.ToString("x2") })
}

function ConvertTo-CanonicalText {
    param([Parameter(Mandatory)][string]$Text)
    $normalized = $Text.Replace("`r`n", "`n").Replace("`r", "`n")
    return $normalized.TrimEnd("`n") + "`n"
}

function Invoke-Captured {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(Mandatory)][string[]]$Arguments,
        [ValidateRange(1, 120)][int]$TimeoutSeconds = 60
    )
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Executable
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $startInfo.ArgumentList.Add($argument) }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) { throw "Provider verification process did not start." }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "Provider verification process exceeded its bounded timeout."
        }
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) {
            throw "Provider verification failed with exit code $($process.ExitCode): $stderr"
        }
        return $stdout
    } finally {
        $process.Dispose()
    }
}

$registryPath = Join-Path $RepoRoot "recipes\meta-vr-cli-evidence-profiles.v1.json"
$registrySchemaPath = Join-Path $RepoRoot "schemas\rusty.quest.workflow.meta_tooling_profile_registry.v1.schema.json"
$receiptPath = Join-Path $RepoRoot "examples\meta-tooling-diagnostic-receipt.synthetic.json"
$receiptSchemaPath = Join-Path $RepoRoot "schemas\rusty.quest.workflow.meta_tooling_diagnostic_receipt.v1.schema.json"

$registryText = Get-Content -Raw -LiteralPath $registryPath
$registry = $registryText | ConvertFrom-Json
$receiptText = Get-Content -Raw -LiteralPath $receiptPath
$receipt = $receiptText | ConvertFrom-Json

if (-not ($registryText | Test-Json -SchemaFile $registrySchemaPath)) {
    throw "Meta tooling profile registry failed JSON Schema validation."
}
if (-not ($receiptText | Test-Json -SchemaFile $receiptSchemaPath)) {
    throw "Synthetic Meta tooling receipt failed JSON Schema validation."
}

$expectedIds = @("health", "logcat", "screenshot", "xr-frame-pacing")
$actualIds = @($registry.profiles.id)
if (($actualIds -join "|") -cne ($expectedIds -join "|")) {
    throw "Profile order or membership drifted."
}
if (@($actualIds | Sort-Object -Unique).Count -ne $actualIds.Count) {
    throw "Duplicate profile ids are forbidden."
}

foreach ($profile in $registry.profiles) {
    $canonical = [string]$profile.config_canonical_json
    $canonicalObject = $canonical | ConvertFrom-Json
    $canonicalRoundTrip = $canonicalObject | ConvertTo-Json -Depth 12 -Compress
    if ($canonicalRoundTrip -cne $canonical) {
        throw "Profile $($profile.id) config is not in the required compact canonical form."
    }
    $typedConfig = $profile.config | ConvertTo-Json -Depth 12 -Compress
    if ($typedConfig -cne $canonical) {
        throw "Profile $($profile.id) typed config differs from its canonical JSON."
    }
    if ((Get-TextSha256 -Text $canonical) -cne [string]$profile.config_sha256) {
        throw "Profile $($profile.id) config SHA-256 drifted."
    }
    foreach ($path in $profile.artifact_paths) {
        if ([string]$path -match '\\|(^|/)\.\.(/|$)|^[A-Za-z]:|^/') {
            throw "Profile $($profile.id) contains a non-portable artifact path."
        }
    }
}

$frameProfile = @($registry.profiles | Where-Object { [string]$_.id -ceq "xr-frame-pacing" })
if ($frameProfile.Count -ne 1 -or
    [string]$frameProfile[0].provider_recipe_id -cne "perfetto-vr" -or
    [string]$frameProfile[0].config.mode -cne "vr" -or
    [string]$frameProfile[0].config.analysis_focus -cne "frames" -or
    [int]$frameProfile[0].config.duration_ms -gt 10000 -or
    [int]$frameProfile[0].config.maximum_duration_ms -gt 30000 -or
    -not [bool]$frameProfile[0].cleanup.required) {
    throw "xr-frame-pacing bounds or cleanup contract drifted."
}

$registryCanonicalText = ConvertTo-CanonicalText -Text $registryText
$registryHash = Get-TextSha256 -Text $registryCanonicalText
$registryCrlfHash = Get-TextSha256 -Text (
    ConvertTo-CanonicalText -Text $registryCanonicalText.Replace("`n", "`r`n")
)
if ($registryCrlfHash -cne $registryHash) {
    throw "Profile registry hash depends on checkout line endings."
}
if ([string]$receipt.registry_sha256 -cne $registryHash) {
    throw "Synthetic receipt does not bind the current profile registry."
}
$receiptProfileId = [string]$receipt.profile_id
$receiptProfile = @($registry.profiles | Where-Object { [string]$_.id -ceq $receiptProfileId })
if ($receiptProfile.Count -ne 1) {
    throw "Synthetic receipt profile binding drifted."
}
if (([string]$receipt.config_sha256) -cne ([string]$receiptProfile[0].config_sha256)) {
    throw "Synthetic receipt config binding drifted."
}
$declaredMetrics = @($receiptProfile[0].metric_summary.id)
foreach ($metric in $receipt.metrics) {
    if ($declaredMetrics -cnotcontains [string]$metric.id) {
        throw "Synthetic receipt contains an undeclared metric: $($metric.id)"
    }
}

if ($VerifyProvider) {
    $npx = (Get-Command npx.cmd -ErrorAction Stop).Source
    $npm = (Get-Command npm.cmd -ErrorAction Stop).Source
    $packageSpec = "$($registry.provider.npm_package)@$($registry.provider.npm_package_version)"
    $version = (Invoke-Captured -Executable $npx -Arguments @("-y", $packageSpec, "--version") -TimeoutSeconds 60).Trim()
    if ($version -cne [string]$registry.provider.observed_cli_version) {
        throw "Observed Meta VR CLI version differs from the registry pin."
    }
    $integrityJson = Invoke-Captured -Executable $npm -Arguments @("view", $packageSpec, "dist.integrity", "--json") -TimeoutSeconds 60
    $integrity = [string]($integrityJson | ConvertFrom-Json)
    if ($integrity -cne [string]$registry.provider.package_integrity_sri) {
        throw "npm distribution integrity differs from the registry pin."
    }
    $markdownRaw = Invoke-Captured -Executable $npx -Arguments @("-y", $packageSpec, "--markdown-help") -TimeoutSeconds 60
    $markdown = (($markdownRaw -split "`r?`n") -join "`n").TrimEnd("`n") + "`n"
    if ((Get-TextSha256 -Text $markdown) -cne [string]$registry.provider.capability_reference.sha256) {
        throw "Normalized Meta VR CLI help SHA-256 differs from the registry pin."
    }
    if ([System.Text.UTF8Encoding]::new($false).GetByteCount($markdown) -ne [int]$registry.provider.capability_reference.size_bytes) {
        throw "Normalized Meta VR CLI help byte count differs from the registry pin."
    }
    $requiredPatterns = @(
        'health-check',
        '(?s)## capture.*?### screenshot',
        '(?s)## perf.*?Capture mode preset:.*?\bvr\b',
        'analyze-trace',
        '--focus'
    )
    foreach ($requiredPattern in $requiredPatterns) {
        if ($markdown -cnotmatch $requiredPattern) {
            throw "Pinned provider help is missing required pattern: $requiredPattern"
        }
    }
}

[ordered]@{
    schema = "rusty.quest.workflow.meta_tooling_profile_validation.v1"
    status = "passed"
    provider_verified = [bool]$VerifyProvider
    provider = "$($registry.provider.npm_package)@$($registry.provider.npm_package_version)"
    cli_version = [string]$registry.provider.observed_cli_version
    registry_sha256 = $registryHash
    profiles = $expectedIds
} | ConvertTo-Json -Depth 5
