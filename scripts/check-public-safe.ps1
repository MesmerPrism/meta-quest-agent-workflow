param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$selfPath = if ($MyInvocation.MyCommand.Path) {
    (Resolve-Path -LiteralPath $MyInvocation.MyCommand.Path).Path
} else {
    ""
}

$failPatterns = @(
    [ordered]@{ name = "windows-drive-path"; pattern = "(?<![A-Za-z])\b[A-Za-z]:[\\/]" },
    [ordered]@{ name = "windows-user-home"; pattern = "C:[\\/]Users[\\/]" },
    [ordered]@{ name = "agent-bureau"; pattern = "Agent Bureau" },
    [ordered]@{ name = "private-repo-rusty-dope"; pattern = "Rusty-DOPE" },
    [ordered]@{ name = "private-repo-rustyality"; pattern = "Rustyality" },
    [ordered]@{ name = "private-repo-companion"; pattern = "DopeCompanion" },
    [ordered]@{ name = "private-repo-vision"; pattern = "Rusty-Vision" },
    [ordered]@{ name = "private-repo-kuramoto"; pattern = "Rusty-Kuramoto" },
    [ordered]@{ name = "private-project-name"; pattern = "Viscereality" },
    [ordered]@{ name = "private-effect-name"; pattern = "Colorama" },
    [ordered]@{ name = "private-study-name"; pattern = "brain-candy|Fraktill" }
)

$warnPatterns = @(
    [ordered]@{ name = "possible-device-serial"; pattern = "\b(?=[A-Z0-9]{12,20}\b)(?=[A-Z0-9]*\d)[A-Z0-9]{12,20}\b" },
    [ordered]@{ name = "possible-secret-word"; pattern = "(?i)\b(secret|password|api[_-]?key|access[_-]?token)\b" }
)

$warnAllowlist = @{
    # Public Meta Help Center article IDs resemble Quest serials but are stable source URLs.
    "possible-device-serial" = @(
        "https://www.facebook.com/help/1093311068161696/",
        "https://www.facebook.com/help/929282808591864/"
    )
}

$files = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force |
    Where-Object {
        $_.FullName -notmatch "[\\/]\.git(?:[\\/]|$)" -and
        $_.FullName -notmatch "[\\/]artifacts[\\/]" -and
        $_.FullName -ine $selfPath
    }

$failures = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
    $text = ""
    try {
        $text = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
    }
    catch {
        continue
    }

    foreach ($entry in $failPatterns) {
        if ([regex]::IsMatch($text, $entry.pattern)) {
            $failures.Add([ordered]@{
                file = $file.FullName
                pattern = $entry.name
            })
        }
    }

    foreach ($entry in $warnPatterns) {
        $warningText = $text
        foreach ($allowedText in $warnAllowlist[$entry.name]) {
            $warningText = $warningText.Replace($allowedText, "")
        }
        if ([regex]::IsMatch($warningText, $entry.pattern)) {
            $warnings.Add([ordered]@{
                file = $file.FullName
                pattern = $entry.name
            })
        }
    }
}

if ($warnings.Count -gt 0) {
    Write-Warning "Potential public-safety warnings:"
    $warnings | ConvertTo-Json -Depth 4 | Write-Host
}

if ($failures.Count -gt 0) {
    $failures | ConvertTo-Json -Depth 4 | Write-Host
    Write-Error "Public-safety check failed."
    exit 1
}

$termuxSidecarPath = Join-Path $resolvedRoot "docs\termux-linux-sidecars.md"
$termuxSidecar = Get-Content -Raw -LiteralPath $termuxSidecarPath
foreach ($requiredBoundary in @(
    "classic TCP ADB lab route",
    "current dynamically assigned TLS connect",
    "127.0.0.1:<current-tls-connect-port>",
    "Do not reuse the classic TCP commands above for this modern TLS route."
)) {
    if (-not $termuxSidecar.Contains($requiredBoundary, [StringComparison]::Ordinal)) {
        Write-Error "Termux ADB port-authority boundary is missing: $requiredBoundary"
        exit 1
    }
}
if ($termuxSidecar.Contains(
    "After an operator or external workflow enables WiFi ADB",
    [StringComparison]::Ordinal
)) {
    Write-Error "Generic WiFi ADB guidance must not imply that modern TLS uses port 5555."
    exit 1
}

$markdownFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Filter "*.md" |
    Where-Object {
        $_.FullName -notmatch "[\\/]\.git(?:[\\/]|$)" -and
        $_.FullName -notmatch "[\\/]artifacts[\\/]"
    }
foreach ($markdownFile in $markdownFiles) {
    $markdownText = Get-Content -Raw -LiteralPath $markdownFile.FullName
    if (
        $markdownFile.FullName -ine $termuxSidecarPath -and
        $markdownText.Contains("127.0.0.1:5555", [StringComparison]::Ordinal)
    ) {
        Write-Error "Fixed-port ADB recipe is not labeled in the canonical route owner: $($markdownFile.FullName)"
        exit 1
    }
    if ($markdownText.Contains("user-authorized WiFi ADB", [StringComparison]::Ordinal)) {
        Write-Error "Generic WiFi ADB wording must distinguish classic TCP from modern TLS: $($markdownFile.FullName)"
        exit 1
    }
}

Write-Host "Public-safety check passed for $resolvedRoot"
