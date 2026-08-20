param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
if (-not $RepoRoot) {
    $RepoRoot = Split-Path -Parent $PSScriptRoot
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$canonicalRepository = "https://github.com/MesmerPrism/meta-quest-agent-workflow.git"
$sourceSkillRoot = Join-Path $RepoRoot "skills\meta-quest-workflow"
$git = @(Get-Command git -ErrorAction Stop | Select-Object -First 1)[0].Source
$pwsh = @(Get-Command pwsh -ErrorAction Stop | Select-Object -First 1)[0].Source
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("meta-quest-playbook-resolver-" + [guid]::NewGuid().ToString("N"))

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

function Write-JsonFile {
    param([string]$Path, [object]$Value)

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $json = $Value | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText(
        $Path,
        $json + [Environment]::NewLine,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

function Invoke-Resolver {
    param([string]$InstalledRoot, [int]$ExpectedExit = 0)

    $resolver = Join-Path $InstalledRoot "scripts\Resolve-PlaybookSource.ps1"
    $output = @(& $pwsh -NoProfile -File $resolver -SkillRoot $InstalledRoot -Json 2>&1)
    $exit = $LASTEXITCODE
    if ($exit -ne $ExpectedExit) {
        throw "Resolver exit mismatch. Expected $ExpectedExit, received $exit. Output: $($output -join ' ')"
    }
    if ($ExpectedExit -ne 0) {
        return $null
    }
    return (($output -join [Environment]::NewLine) | ConvertFrom-Json)
}

try {
    $fixtureRoot = Join-Path $tempRoot "source"
    $fixtureSkillRoot = Join-Path $fixtureRoot "skills\meta-quest-workflow"
    $installedRoot = Join-Path $tempRoot "installed\meta-quest-workflow"
    New-Item -ItemType Directory -Force -Path $fixtureRoot | Out-Null
    Copy-Item -LiteralPath $sourceSkillRoot -Destination $fixtureSkillRoot -Recurse
    New-Item -ItemType Directory -Force -Path (Join-Path $fixtureRoot "docs") | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot "README.md") -Destination (Join-Path $fixtureRoot "README.md")
    Copy-Item -LiteralPath (Join-Path $RepoRoot "docs\playbook-index.md") -Destination (Join-Path $fixtureRoot "docs\playbook-index.md")

    & $git -C $fixtureRoot init --initial-branch main | Out-Null
    & $git -C $fixtureRoot config user.email "resolver-test@example.invalid"
    & $git -C $fixtureRoot config user.name "Resolver Test"
    & $git -C $fixtureRoot remote add origin $canonicalRepository
    & $git -C $fixtureRoot add --all
    & $git -C $fixtureRoot commit -m "resolver fixture" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create resolver Git fixture."
    }
    $commit = ([string](& $git -C $fixtureRoot rev-parse HEAD)).Trim()
    $tree = ([string](& $git -C $fixtureRoot rev-parse 'HEAD^{tree}')).Trim()

    Copy-Item -LiteralPath $fixtureSkillRoot -Destination $installedRoot -Recurse
    $prefix = "skills/meta-quest-workflow/"
    $sourceFiles = @(
        & $git -C $fixtureRoot ls-files -- $prefix |
            Sort-Object -CaseSensitive |
            ForEach-Object {
                $relative = $_.Substring($prefix.Length)
                [ordered]@{
                    path = $relative.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
                    sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $installedRoot $relative)).Hash.ToLowerInvariant()
                }
            }
    )
    $fingerprintInput = (($sourceFiles | ForEach-Object { "$($_.path):$($_.sha256)" }) -join "`n") + "`n"
    $provenance = [ordered]@{
        schema = "rusty.morphospace.local_skill_source.v1"
        skill_id = "meta-quest-workflow"
        installed_at = [DateTime]::UtcNow.ToString("o")
        source_repository = $canonicalRepository
        source_commit = $commit
        source_worktree_dirty = $false
        source_release = $null
        source_tree_sha256 = Get-StringSha256 -Text $fingerprintInput
        source_files = $sourceFiles
        work_environment_root = (Join-Path $tempRoot "work-environment")
    }
    Write-JsonFile -Path (Join-Path $installedRoot ".morphospace-skill-source.json") -Value $provenance

    $locator = [ordered]@{
        schema = "rusty.quest.workflow.local_playbook_source.v1"
        skill_id = "meta-quest-workflow"
        repository_root = $fixtureRoot
        source_repository = $canonicalRepository
        source_commit = $commit
        source_tree = $tree
        source_worktree_dirty = $false
        source_status_fingerprint = Get-StringSha256 -Text ""
        readme_path = (Join-Path $fixtureRoot "README.md")
        docs_root = (Join-Path $fixtureRoot "docs")
        playbook_index_path = (Join-Path $fixtureRoot "docs\playbook-index.md")
    }
    $locatorPath = Join-Path $installedRoot "references\local-meta-quest-playbooks.json"
    Write-JsonFile -Path $locatorPath -Value $locator

    $local = Invoke-Resolver -InstalledRoot $installedRoot
    if ($local.mode -cne "local" -or
        $local.source_commit -cne $commit -or
        $local.source_tree -cne $tree -or
        -not ([string]$local.repository_root).Equals($fixtureRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Resolver rejected an exact clean local playbook source: $($local | ConvertTo-Json -Compress)"
    }

    [System.IO.File]::WriteAllText((Join-Path $fixtureRoot "dirty.tmp"), "dirty")
    $dirty = Invoke-Resolver -InstalledRoot $installedRoot
    if ($dirty.mode -cne "pinned-public" -or
        -not $dirty.playbook_index.Contains("/$commit/", [System.StringComparison]::Ordinal) -or
        $dirty.playbook_index.Contains("/main/", [System.StringComparison]::Ordinal)) {
        throw "Resolver did not reject a dirty local playbook source with a pinned-public fallback."
    }
    Remove-Item -LiteralPath (Join-Path $fixtureRoot "dirty.tmp") -Force

    $damagedLocator = [ordered]@{} + $locator
    $damagedLocator.source_tree = "0" * 40
    Write-JsonFile -Path $locatorPath -Value $damagedLocator
    $damaged = Invoke-Resolver -InstalledRoot $installedRoot
    if ($damaged.mode -cne "pinned-public" -or $damaged.source_commit -cne $commit) {
        throw "Resolver did not reject a damaged locator."
    }

    Remove-Item -LiteralPath $locatorPath -Force
    $absent = Invoke-Resolver -InstalledRoot $installedRoot
    if ($absent.mode -cne "pinned-public" -or $absent.reason -cne "local-locator-absent") {
        throw "Resolver did not use the pinned-public fallback for an absent locator."
    }

    Write-JsonFile -Path $locatorPath -Value $locator
    Add-Content -LiteralPath (Join-Path $installedRoot "agents\openai.yaml") -Value "# drift"
    Invoke-Resolver -InstalledRoot $installedRoot -ExpectedExit 1

    Write-Host "Meta Quest playbook source resolver tests passed."
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
