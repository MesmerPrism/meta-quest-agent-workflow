param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$routingPath = Join-Path $resolvedRoot "docs\rusty-morphospace-repo-routing.md"

if (-not (Test-Path -LiteralPath $routingPath -PathType Leaf)) {
    throw "Missing Rusty Morphospace routing document: $routingPath"
}

$routing = Get-Content -Raw -LiteralPath $routingPath
$requiredRepositories = @(
    "rusty-morphospace-work-environment",
    "QuestIonAble-File-Manager",
    "rusty-manifold",
    "rusty-manifold-packages",
    "rusty-matter",
    "rusty-optics",
    "rusty-lattice",
    "rusty-lsl",
    "rusty-gui",
    "rusty-quest",
    "rusty-hostess",
    "rusty-fleet",
    "quest-termux-lab",
    "rusty-quest-sidecar-mesh"
)

$failures = New-Object System.Collections.Generic.List[string]
foreach ($repository in $requiredRepositories) {
    $url = "https://github.com/MesmerPrism/$repository"
    if (-not $routing.Contains($url, [System.StringComparison]::Ordinal)) {
        $failures.Add("missing repository link: $url")
    }
}

$activeFiles = @(
    "README.md",
    "docs\agent-execution-providers.md",
    "docs\accessibility-foreground-watchdogs.md",
    "docs\quest-capture-stack-notes.md",
    "docs\quest-signal-patterns.md"
)
$legacyPatterns = @(
    "MesmerPrism/Rusty-XR",
    "RustyXr.Companion.Cli",
    "RUSTY_XR_MAKEPAD",
    "/rustyxr/"
)

foreach ($relativePath in $activeFiles) {
    $path = Join-Path $resolvedRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failures.Add("missing active routing surface: $relativePath")
        continue
    }
    $content = Get-Content -Raw -LiteralPath $path
    foreach ($pattern in $legacyPatterns) {
        if ($content.Contains($pattern, [System.StringComparison]::OrdinalIgnoreCase)) {
            $failures.Add("legacy active-route token '$pattern' in $relativePath")
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Rusty Morphospace routing check passed for $resolvedRoot"
