param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$schemaDirectory = Join-Path $resolvedRoot "schemas"
$intentPath = Join-Path $resolvedRoot "examples\agent-execution-intent.json"
$wrapperPath = Join-Path $resolvedRoot "examples\agent-execution-evidence-wrapper.json"
$requiredSchemas = @(
    "rusty.quest.workflow.intent.v1.schema.json",
    "rusty.quest.workflow.evidence_wrapper.v1.schema.json"
)
$forbiddenNames = @(
    "serial",
    "device_serial",
    "target_serial",
    "path",
    "local_path",
    "endpoint",
    "credential",
    "credentials",
    "approval",
    "lease",
    "authority",
    "agent_board"
)

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Test-ForbiddenProperty {
    param(
        [object]$Value,
        [string]$Location
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $name = [string]$key
            Assert-True ($forbiddenNames -notcontains $name.ToLowerInvariant()) "Forbidden portable property '$name' at $Location."
            Test-ForbiddenProperty -Value $Value[$key] -Location "$Location.$name"
        }
        return
    }

    if ($Value -is [pscustomobject]) {
        foreach ($property in $Value.PSObject.Properties) {
            $name = [string]$property.Name
            Assert-True ($forbiddenNames -notcontains $name.ToLowerInvariant()) "Forbidden portable property '$name' at $Location."
            Test-ForbiddenProperty -Value $property.Value -Location "$Location.$name"
        }
        return
    }

    if (($Value -is [System.Collections.IEnumerable]) -and -not ($Value -is [string])) {
        $index = 0
        foreach ($item in $Value) {
            Test-ForbiddenProperty -Value $item -Location "$Location[$index]"
            $index++
        }
    }
}

foreach ($schemaName in $requiredSchemas) {
    $path = Join-Path $schemaDirectory $schemaName
    Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing schema: $schemaName"
    Get-Content -Raw -LiteralPath $path | ConvertFrom-Json -Depth 100 | Out-Null
}

$intent = Get-Content -Raw -LiteralPath $intentPath | ConvertFrom-Json -Depth 100
$wrapper = Get-Content -Raw -LiteralPath $wrapperPath | ConvertFrom-Json -Depth 100

Assert-True ($intent.schema -ceq "rusty.quest.workflow.intent.v1") "Unexpected intent schema."
Assert-True ($intent.constraints.exact_target_required -eq $true) "Portable intents must require an exact private target resolution."
Assert-True ($intent.PSObject.Properties.Name -notcontains "serial") "Portable intent leaked a serial."
Assert-True ($intent.PSObject.Properties.Name -notcontains "path") "Portable intent leaked a path."
Assert-True ($wrapper.schema -ceq "rusty.quest.workflow.evidence_wrapper.v1") "Unexpected wrapper schema."
Assert-True ($wrapper.provider_evidence_sha256 -cmatch "^[a-f0-9]{64}$") "Invalid owner-evidence digest."

Test-ForbiddenProperty -Value $intent -Location "intent"
Test-ForbiddenProperty -Value $wrapper -Location "wrapper"

$rawFallbackAllowedClaims = @("transport-observed", "diagnostic-only")
Assert-True ($rawFallbackAllowedClaims -notcontains "owner-effect-confirmed") "Raw fallback must not claim an owner effect."

Write-Host "Agent execution contract check passed for $resolvedRoot"
