param(
    [string]$SkillRoot = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$canonicalRepository = "https://github.com/MesmerPrism/meta-quest-agent-workflow.git"
$canonicalRawRoot = "https://raw.githubusercontent.com/MesmerPrism/meta-quest-agent-workflow"
$pathComparison = if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
        [System.Runtime.InteropServices.OSPlatform]::Windows
    )) {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}

if (-not $SkillRoot) {
    $SkillRoot = Split-Path -Parent $PSScriptRoot
}
$SkillRoot = (Resolve-Path -LiteralPath $SkillRoot).Path

function Get-StringSha256 {
    param([string]$Text)

    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")
    } finally {
        $sha.Dispose()
    }
}

function Test-FullHex {
    param([string]$Value, [int]$Length)

    return $Value -cmatch "^[0-9a-f]{$Length}$"
}

function ConvertTo-CanonicalRepository {
    param([string]$Repository)

    $value = $Repository.Trim()
    if ($value -match '^(?i:https://github\.com/|git@github\.com:)([^/]+)/(.+?)(?:\.git)?$') {
        return "https://github.com/$($Matches[1])/$($Matches[2]).git"
    }
    return $value
}

function Resolve-SkillFile {
    param([string]$RelativePath)

    $normalized = $RelativePath.Replace('\', '/')
    if ([string]::IsNullOrWhiteSpace($normalized) -or
        [System.IO.Path]::IsPathRooted($normalized) -or
        $normalized -eq ".." -or
        $normalized.StartsWith("../", [System.StringComparison]::Ordinal) -or
        $normalized.Contains("/../", [System.StringComparison]::Ordinal)) {
        throw "Installed skill provenance contains an unsafe source-file path."
    }

    $root = [System.IO.Path]::GetFullPath($SkillRoot)
    $prefix = $root.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $root $normalized))
    if (-not $candidate.StartsWith($prefix, $pathComparison)) {
        throw "Installed skill provenance source-file path escaped the skill root."
    }
    return $candidate
}

function Get-PinnedPublicResolution {
    param([object]$Provenance, [string]$Reason)

    $commit = [string]$Provenance.source_commit
    return [ordered]@{
        schema = "rusty.quest.workflow.playbook_source_resolution.v1"
        mode = "pinned-public"
        source_repository = $canonicalRepository
        source_commit = $commit
        source_tree = $null
        repository_root = $null
        readme = "$canonicalRawRoot/$commit/README.md"
        docs_root = "$canonicalRawRoot/$commit/docs"
        playbook_index = "$canonicalRawRoot/$commit/docs/playbook-index.md"
        reason = $Reason
    }
}

function Invoke-GitText {
    param([string]$Git, [string]$RepositoryRoot, [string[]]$Arguments)

    $lines = @(& $Git -C $RepositoryRoot @Arguments 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Git inspection failed."
    }
    return ($lines -join "`n").Trim()
}

$provenancePath = Join-Path $SkillRoot ".morphospace-skill-source.json"
if (-not (Test-Path -LiteralPath $provenancePath -PathType Leaf)) {
    throw "Installed Meta Quest skill provenance is absent. Use the repository checkout directly or reinstall the skill."
}
try {
    $provenance = Get-Content -Raw -LiteralPath $provenancePath | ConvertFrom-Json
} catch {
    throw "Installed Meta Quest skill provenance is invalid JSON."
}

if ($provenance.schema -cne "rusty.morphospace.local_skill_source.v1" -or
    $provenance.skill_id -cne "meta-quest-workflow" -or
    (ConvertTo-CanonicalRepository -Repository ([string]$provenance.source_repository)) -cne $canonicalRepository -or
    -not (Test-FullHex -Value ([string]$provenance.source_commit) -Length 40) -or
    [bool]$provenance.source_worktree_dirty) {
    throw "Installed Meta Quest skill provenance is not a clean, commit-pinned canonical source."
}

$sourceFiles = @($provenance.source_files)
if ($sourceFiles.Count -lt 3) {
    throw "Installed Meta Quest skill provenance has no complete managed-file inventory."
}
$sourcePaths = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::Ordinal)
$fingerprintLines = New-Object System.Collections.Generic.List[string]
foreach ($sourceFile in $sourceFiles) {
    $sourcePath = ([string]$sourceFile.path).Replace('\', '/')
    $expectedHash = ([string]$sourceFile.sha256).ToLowerInvariant()
    if (-not (Test-FullHex -Value $expectedHash -Length 64)) {
        throw "Installed Meta Quest skill provenance contains an invalid managed-file hash."
    }
    if (-not $sourcePaths.Add($sourcePath)) {
        throw "Installed Meta Quest skill provenance contains duplicate managed-file paths."
    }
    $fingerprintLines.Add("$([string]$sourceFile.path):$expectedHash")
    $installedPath = Resolve-SkillFile -RelativePath $sourcePath
    if (-not (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
        throw "Installed Meta Quest skill is missing a provenance-bound managed file."
    }
    $installedItem = Get-Item -LiteralPath $installedPath -Force
    if (($installedItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Installed Meta Quest skill rejects reparse-point managed files."
    }
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $installedPath).Hash.ToLowerInvariant()
    if ($actualHash -cne $expectedHash) {
        throw "Installed Meta Quest skill managed files drifted from provenance."
    }
}
foreach ($requiredSourcePath in @(
    "SKILL.md",
    "agents/openai.yaml",
    "scripts/Resolve-PlaybookSource.ps1"
)) {
    if (-not $sourcePaths.Contains($requiredSourcePath)) {
        throw "Installed Meta Quest skill provenance is missing a required managed file."
    }
}
$fingerprintText = ($fingerprintLines -join "`n") + "`n"
if (-not (Test-FullHex -Value ([string]$provenance.source_tree_sha256) -Length 64) -or
    (Get-StringSha256 -Text $fingerprintText) -cne [string]$provenance.source_tree_sha256) {
    throw "Installed Meta Quest skill provenance managed-file fingerprint is invalid."
}

$locatorPath = Join-Path $SkillRoot "references\local-meta-quest-playbooks.json"
$resolution = $null
if (-not (Test-Path -LiteralPath $locatorPath -PathType Leaf)) {
    $resolution = Get-PinnedPublicResolution -Provenance $provenance -Reason "local-locator-absent"
} else {
    try {
        $locator = Get-Content -Raw -LiteralPath $locatorPath | ConvertFrom-Json
        if ($locator.schema -cne "rusty.quest.workflow.local_playbook_source.v1" -or
            $locator.skill_id -cne "meta-quest-workflow" -or
            (ConvertTo-CanonicalRepository -Repository ([string]$locator.source_repository)) -cne $canonicalRepository -or
            [string]$locator.source_commit -cne [string]$provenance.source_commit -or
            -not (Test-FullHex -Value ([string]$locator.source_tree) -Length 40) -or
            -not (Test-FullHex -Value ([string]$locator.source_status_fingerprint) -Length 64) -or
            [bool]$locator.source_worktree_dirty) {
            throw "locator-identity"
        }

        $repositoryRoot = (Resolve-Path -LiteralPath ([string]$locator.repository_root)).Path
        $repositoryItem = Get-Item -LiteralPath $repositoryRoot -Force
        if (($repositoryItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "locator-reparse-root"
        }

        $expectedReadme = Join-Path $repositoryRoot "README.md"
        $expectedDocs = Join-Path $repositoryRoot "docs"
        $expectedIndex = Join-Path $expectedDocs "playbook-index.md"
        if (-not ([string]$locator.readme_path).Equals($expectedReadme, $pathComparison) -or
            -not ([string]$locator.docs_root).Equals($expectedDocs, $pathComparison) -or
            -not ([string]$locator.playbook_index_path).Equals($expectedIndex, $pathComparison) -or
            -not (Test-Path -LiteralPath $expectedReadme -PathType Leaf) -or
            -not (Test-Path -LiteralPath $expectedDocs -PathType Container) -or
            -not (Test-Path -LiteralPath $expectedIndex -PathType Leaf)) {
            throw "locator-playbook-paths"
        }

        $git = @(Get-Command git -ErrorAction Stop | Select-Object -First 1)[0].Source
        $gitRoot = [System.IO.Path]::GetFullPath((
            Invoke-GitText -Git $git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "--show-toplevel")
        ))
        $head = Invoke-GitText -Git $git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
        $tree = Invoke-GitText -Git $git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", 'HEAD^{tree}')
        $remote = Invoke-GitText -Git $git -RepositoryRoot $repositoryRoot -Arguments @("remote", "get-url", "origin")
        $statusLines = @(& $git -C $repositoryRoot status --porcelain --untracked-files=normal | Sort-Object -CaseSensitive)
        if ($LASTEXITCODE -ne 0) {
            throw "locator-status"
        }
        $statusText = if ($statusLines.Count -eq 0) { "" } else { ($statusLines -join "`n") + "`n" }
        $statusFingerprint = Get-StringSha256 -Text $statusText

        if (-not $gitRoot.Equals($repositoryRoot, $pathComparison) -or
            $head -cne [string]$locator.source_commit -or
            $tree -cne [string]$locator.source_tree -or
            (ConvertTo-CanonicalRepository -Repository $remote) -cne $canonicalRepository -or
            $statusLines.Count -ne 0 -or
            $statusFingerprint -cne [string]$locator.source_status_fingerprint) {
            throw "locator-live-source"
        }

        $resolution = [ordered]@{
            schema = "rusty.quest.workflow.playbook_source_resolution.v1"
            mode = "local"
            source_repository = $canonicalRepository
            source_commit = $head
            source_tree = $tree
            repository_root = $repositoryRoot
            readme = $expectedReadme
            docs_root = $expectedDocs
            playbook_index = $expectedIndex
            reason = "validated-local-source"
        }
    } catch {
        $resolution = Get-PinnedPublicResolution -Provenance $provenance -Reason "local-locator-invalid-or-stale"
    }
}

if ($Json) {
    $resolution | ConvertTo-Json -Depth 8
} else {
    [pscustomobject]$resolution
}
