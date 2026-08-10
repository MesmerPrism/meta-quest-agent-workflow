param([string]$RepoRoot = "")

$ErrorActionPreference = "Stop"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$registry = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot "recipes\verified-quest-diagnostics.v1.json") | ConvertFrom-Json
if ([string]$registry.schema -cne "rusty.quest.workflow.diagnostic_recipe_registry.v1") { throw "Registry schema drifted." }
$ids = @($registry.recipes.id)
$expected = @("health", "foreground", "logcat-clear", "logcat", "screenshot", "perfetto-vr")
if (($ids -join "|") -cne ($expected -join "|")) { throw "Registry recipe order or membership drifted." }
if (@($registry.recipes | Where-Object authority -notin @("transport-observed", "diagnostic-only")).Count -ne 0) { throw "Registry contains an invalid authority claim." }
$adapterText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot "scripts\Invoke-VerifiedQuestDiagnostic.ps1")
if ($adapterText -notmatch 'ANDROID_SERIAL\s*=\s*\$Serial') { throw "Nested ADB serial pin drifted." }
$output = & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "scripts\Invoke-VerifiedQuestDiagnostic.ps1") -SelfTest
if ($LASTEXITCODE -ne 0 -or [string]($output | ConvertFrom-Json).status -cne "passed") { throw "Diagnostic adapter self-test failed." }
Write-Host "Verified Quest diagnostic registry and vectors passed."
