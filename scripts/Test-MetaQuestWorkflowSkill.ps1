param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

if (-not $RepoRoot) {
    $RepoRoot = Split-Path -Parent $PSScriptRoot
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$skillRoot = Join-Path $RepoRoot "skills\meta-quest-workflow"
$skillPath = Join-Path $skillRoot "SKILL.md"
$agentPath = Join-Path $skillRoot "agents\openai.yaml"
$locatorPath = Join-Path $skillRoot "references\local-work-environment.json"
$playbookLocatorPath = Join-Path $skillRoot "references\local-meta-quest-playbooks.json"
$resolverPath = Join-Path $skillRoot "scripts\Resolve-PlaybookSource.ps1"
$readmePath = Join-Path $RepoRoot "README.md"
$agentsPath = Join-Path $RepoRoot "AGENTS.md"
$playbookResolutionPath = Join-Path $RepoRoot "docs\local-playbook-resolution.md"
$playbookIndexPath = Join-Path $RepoRoot "docs\playbook-index.md"
$resolverTestPath = Join-Path $RepoRoot "scripts\Test-PlaybookSourceResolver.ps1"
$mutationPath = Join-Path $RepoRoot "docs\host-headset-mutation-confirmation.md"
$signalsPath = Join-Path $RepoRoot "docs\quest-signal-patterns.md"

foreach ($path in @(
    $skillPath,
    $agentPath,
    $resolverPath,
    $readmePath,
    $agentsPath,
    $playbookResolutionPath,
    $playbookIndexPath,
    $resolverTestPath,
    $mutationPath,
    $signalsPath
)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Canonical Meta Quest skill file is missing: $path"
    }
}

$skillLines = @(Get-Content -LiteralPath $skillPath)
if ($skillLines.Count -lt 5 -or
    $skillLines[0] -cne "---" -or
    $skillLines[3] -cne "---") {
    throw "Canonical Meta Quest skill frontmatter must contain exactly name and description."
}
if ($skillLines[1] -notmatch '^name: ([a-z0-9-]+)$') {
    throw "Canonical Meta Quest skill frontmatter has an invalid name."
}
$skillName = $Matches[1]
if ($skillName -cne "meta-quest-workflow" -or
    $skillLines[2] -notmatch "^description: '[^']+'$") {
    throw "Canonical Meta Quest skill frontmatter identity is invalid."
}
if ((Split-Path -Leaf $skillRoot) -cne $skillName) {
    throw "Canonical Meta Quest skill name does not match its directory."
}

$agentLines = @(Get-Content -LiteralPath $agentPath | Where-Object { $_.Trim().Length -gt 0 })
if ($agentLines.Count -ne 4 -or
    $agentLines[0] -cne "interface:" -or
    $agentLines[1] -notmatch '^  display_name: "([^"]+)"$') {
    throw "Canonical Meta Quest agent manifest has an invalid interface structure."
}
$displayName = $Matches[1]
if ($agentLines[2] -notmatch '^  short_description: "([^"]+)"$') {
    throw "Canonical Meta Quest agent manifest has an invalid short_description."
}
$shortDescription = $Matches[1]
if ($shortDescription.Length -lt 25 -or $shortDescription.Length -gt 64) {
    throw "Canonical Meta Quest agent short_description must be 25 through 64 characters."
}
if ($agentLines[3] -notmatch '^  default_prompt: "([^"]+)"$') {
    throw "Canonical Meta Quest agent manifest has an invalid default_prompt."
}
$defaultPrompt = $Matches[1]
if (-not $defaultPrompt.Contains('$meta-quest-workflow', [System.StringComparison]::Ordinal)) {
    throw "Canonical Meta Quest agent default_prompt must name `$meta-quest-workflow."
}
if ([string]::IsNullOrWhiteSpace($displayName)) {
    throw "Canonical Meta Quest agent display_name is empty."
}
if (Test-Path -LiteralPath $locatorPath) {
    throw "The canonical skill source must not track generated local-work-environment metadata."
}
if (Test-Path -LiteralPath $playbookLocatorPath) {
    throw "The canonical skill source must not track generated local playbook metadata."
}

$skill = Get-Content -Raw -LiteralPath $skillPath
$agent = Get-Content -Raw -LiteralPath $agentPath
$requiredSkillTokens = @(
    "name: meta-quest-workflow",
    "references/local-work-environment.json",
    "references/local-meta-quest-playbooks.json",
    "Resolve-PlaybookSource.ps1",
    "pinned-public",
    'never floating `main`',
    "docs/QUEST_APK_WORKFLOW.md",
    "docs/PROJECT_ISOLATION.md",
    "docs/PUBLIC_PRIVATE_BOUNDARY.md",
    "docs/INSTRUCTION_SYNCHRONIZATION.md",
    "canonical skill",
    "cannot override this repository's",
    "never guess a machine path",
    "Quest Reboot Is Attended",
    "physical power button",
    "SensorLockActivity",
    "target process owns the OpenXR",
    "File Manager inspected deployment",
    "Fleet approved execution",
    "Kiosk"
)
foreach ($token in $requiredSkillTokens) {
    if (-not $skill.Contains($token, [System.StringComparison]::Ordinal)) {
        throw "Canonical Meta Quest skill is missing required token: $token"
    }
}

$requiredSynchronizedTokens = [ordered]@{
    $readmePath = @("Treat Quest reboot as attended recovery", "target-owned requested-rate OpenXR readiness", "local playbook locator")
    $agentsPath = @("Quest reboot as an attended recovery boundary", "power-button/wearer gate", "installed provenance commit")
    $playbookResolutionPath = @("portable router", "source_status_fingerprint", 'floating `main`')
    $playbookIndexPath = @("Local playbook resolution", "locator grants no runtime authority")
    $mutationPath = @("Reboot is an attended boundary", "sys.boot_completed=1", "VolumetricWindowManagerServiceImpl")
    $signalsPath = @("Post-Reboot Sensor Lock And Volumetric Placement", 'A `VrApi` line from Meta Shell at 72 Hz', "Require the target PID")
}
foreach ($entry in $requiredSynchronizedTokens.GetEnumerator()) {
    $content = Get-Content -Raw -LiteralPath $entry.Key
    foreach ($token in $entry.Value) {
        if (-not $content.Contains($token, [System.StringComparison]::Ordinal)) {
            throw "Synchronized Quest reboot guidance is missing required token '$token' from $($entry.Key)"
        }
    }
}

$requiredAgentTokens = @(
    'display_name: "Meta Quest Workflow"',
    'short_description: "Quest ecosystem routing and validation"',
    'default_prompt:',
    '$meta-quest-workflow',
    "File Manager",
    "Kiosk",
    "Fleet"
)
foreach ($token in $requiredAgentTokens) {
    if (-not $agent.Contains($token, [System.StringComparison]::Ordinal)) {
        throw "Canonical Meta Quest agent manifest is missing required token: $token"
    }
}

if ($skill -match '(?im)(?:[A-Z]:\\|/Users/|/home/|private-planning|device serial\s*[:=])') {
    throw "Canonical Meta Quest skill contains a local or private identity."
}
if ($agent -match '(?im)(?:[A-Z]:\\|/Users/|/home/|private-planning|device serial\s*[:=])') {
    throw "Canonical Meta Quest agent manifest contains a local or private identity."
}

& $resolverTestPath -RepoRoot $RepoRoot

Write-Host "Canonical Meta Quest workflow skill validation passed."
