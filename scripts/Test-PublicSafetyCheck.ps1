param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [Parameter(Mandatory)][string]$EvidenceDirectory
)
$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
if (Test-Path -LiteralPath $EvidenceDirectory) { throw 'Evidence directory must be create-new' }
New-Item -ItemType Directory -Path $EvidenceDirectory | Out-Null
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('meta-public-safe-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
$checker = Join-Path $RepoRoot 'scripts/check-public-safe.ps1'
$pwsh = @(Get-Command pwsh -CommandType Application)[0].Source
$git = @(Get-Command git -CommandType Application)[0].Source
$utf8 = [Text.UTF8Encoding]::new($false)
$cases = [Collections.Generic.List[object]]::new()
function WriteFixture([string]$Path, [string]$Text) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}
function NewFixture([string]$Name, [bool]$UseGit = $true) {
    $root = Join-Path $fixtureRoot $Name
    New-Item -ItemType Directory -Path (Join-Path $root 'scripts') | Out-Null
    Copy-Item -LiteralPath $checker -Destination (Join-Path $root 'scripts/check-public-safe.ps1')
    New-Item -ItemType Directory -Path (Join-Path $root 'docs') | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'docs/termux-linux-sidecars.md') -Destination (Join-Path $root 'docs/termux-linux-sidecars.md')
    if ($UseGit) {
        & $git -C $root init --quiet
        if ($LASTEXITCODE) { throw 'Fixture Git init failed' }
        WriteFixture (Join-Path $root '.gitignore') ".local/`n"
        & $git -C $root add -- .
        if ($LASTEXITCODE) { throw 'Fixture Git add failed' }
    }
    $root
}
function RunCase([string]$Name, [string]$Script, [string]$Cwd, [string]$ExplicitRoot, [bool]$Pass) {
    $start = [Diagnostics.ProcessStartInfo]::new($pwsh)
    $start.WorkingDirectory = $Cwd
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($value in @('-NoProfile', '-File', $Script)) { $start.ArgumentList.Add($value) }
    if ($ExplicitRoot) { $start.ArgumentList.Add('-Root'); $start.ArgumentList.Add($ExplicitRoot) }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        $exit = $process.ExitCode
    } finally { $process.Dispose() }
    WriteFixture (Join-Path $EvidenceDirectory "$Name.stdout.log") $stdout
    WriteFixture (Join-Path $EvidenceDirectory "$Name.stderr.log") $stderr
    if (($exit -eq 0) -ne $Pass) { throw "Unexpected checker result for $Name (exit $exit)" }
    $cases.Add(@{case=$Name;exit=$exit;expected_pass=$Pass})
}
$badText = 'Z' + ':' + '/fixture-only'
$owner = NewFixture 'owner'
$caller = NewFixture 'caller' $false
WriteFixture (Join-Path $caller 'private.txt') $badText
$actual = Join-Path $owner 'scripts/check-public-safe.ps1'
$oldText = (& $git -C $RepoRoot show '94b67b8d724160865e57e785e944798e44d880a8:scripts/check-public-safe.ps1') -join "`n"
if ($LASTEXITCODE) { throw 'Cannot load baseline counterfactual' }
$old = Join-Path $owner '.local/baseline-check.ps1'
WriteFixture $old $oldText
RunCase 'baseline-wrong-cwd-denies' $old $caller '' $false
RunCase 'owner-default-ignores-caller' $actual $caller '' $true
RunCase 'explicit-root-still-scans-requested' $actual $owner $caller $false
WriteFixture (Join-Path $owner 'empty.txt') ''
WriteFixture (Join-Path $owner 'empty.md') ''
RunCase 'baseline-empty-file-throws' $old $owner $owner $false
RunCase 'empty-publishable-files-pass' $actual $caller '' $true
WriteFixture (Join-Path $owner '.local/private.txt') $badText
WriteFixture (Join-Path $owner '.local/private.md') '127.0.0.1:5555'
RunCase 'baseline-ignored-evidence-denies' $old $owner $owner $false
RunCase 'ignored-evidence-excluded-from-both-scans' $actual $caller '' $true
WriteFixture (Join-Path $owner 'new.txt') $badText
RunCase 'untracked-publishable-denies' $actual $caller '' $false
WriteFixture (Join-Path $owner 'new.txt') 'safe fixture'
& $git -C $owner add --force -- .local/private.txt
if ($LASTEXITCODE) { throw 'Force-track fixture failed' }
RunCase 'force-tracked-ignored-denies' $actual $caller '' $false
Remove-Item -LiteralPath (Join-Path $owner '.local/private.txt')
RunCase 'deleted-worktree-file-not-publishable' $actual $caller '' $true
WriteFixture (Join-Path $owner "unicode-$([char]0x03bb) space.txt") $badText
RunCase 'nul-inventory-unicode-space-path-denies' $actual $caller '' $false
$archive = NewFixture 'archive' $false
RunCase 'portable-source-archive-passes' (Join-Path $archive 'scripts/check-public-safe.ps1') $caller '' $true
WriteFixture (Join-Path $archive 'bad.md') $badText
RunCase 'portable-source-archive-denies-public-failure' (Join-Path $archive 'scripts/check-public-safe.ps1') $caller '' $false
WriteFixture (Join-Path $archive 'bad.md') ''
WriteFixture (Join-Path $archive 'docs/termux-linux-sidecars.md') ''
RunCase 'empty-required-route-denies' (Join-Path $archive 'scripts/check-public-safe.ps1') $caller '' $false
$result = @{status='passed';cases=$cases;count=$cases.Count;fixture_root=$fixtureRoot;source_sha256=(Get-FileHash $checker).Hash.ToLowerInvariant();physical_effects=0}
$result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $EvidenceDirectory 'result.json') -Encoding utf8
$result | Select-Object status,count,physical_effects | ConvertTo-Json
