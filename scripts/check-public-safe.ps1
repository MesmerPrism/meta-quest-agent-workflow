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

$files = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force |
    Where-Object {
        $_.FullName -notmatch "[\\/]\.git[\\/]" -and
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
        if ([regex]::IsMatch($text, $entry.pattern)) {
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

Write-Host "Public-safety check passed for $resolvedRoot"
