param(
    [string]$Root = ".",
    [string]$ProviderDiscoveryPath = "",
    [string]$ValidationNowUtc = ""
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$schemaDirectory = Join-Path $resolvedRoot "schemas"
$intentPath = Join-Path $resolvedRoot "examples\agent-execution-intent.json"
$wrapperPath = Join-Path $resolvedRoot "examples\agent-execution-evidence-wrapper.json"
$discoveryPath = Join-Path $resolvedRoot "examples\provider-capability-discovery.json"
$requiredSchemas = @(
    "rusty.quest.workflow.intent.v1.schema.json",
    "rusty.quest.workflow.evidence_wrapper.v1.schema.json",
    "rusty.quest.workflow.provider_capability_discovery.v1.schema.json"
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

function Assert-ExactProperties {
    param(
        [object]$Value,
        [string[]]$Expected,
        [string]$Location
    )

    Assert-True ($Value -is [pscustomobject]) "$Location must be an object."
    $actual = @($Value.PSObject.Properties.Name | Sort-Object)
    $wanted = @($Expected | Sort-Object)
    Assert-True (
        ($actual.Count -eq $wanted.Count) -and
        (($actual -join "`n") -ceq ($wanted -join "`n"))
    ) "$Location has unknown, missing, duplicated, or incorrectly cased properties."
}

function Assert-BoundedStringArray {
    param(
        [object[]]$Values,
        [int]$Minimum,
        [int]$Maximum,
        [string]$Pattern,
        [string]$Location
    )

    $items = @($Values)
    Assert-True (
        $items.Count -ge $Minimum -and $items.Count -le $Maximum
    ) "$Location has an invalid item count."
    foreach ($item in $items) {
        Assert-True (
            ($item -is [string]) -and
            ([string]$item -cmatch $Pattern)
        ) "$Location contains an invalid value."
    }
    Assert-True (
        @($items | Sort-Object -Unique).Count -eq $items.Count
    ) "$Location contains a duplicate value."
}

function Assert-JsonArray {
    param(
        [object]$Value,
        [string]$Location
    )

    Assert-True (
        $Value -is [System.Array]
    ) "$Location must be a JSON array."
}

function Assert-SafeDiscoveryIdentifier {
    param(
        [string]$Value,
        [string]$Location
    )

    $normalized = $Value.ToLowerInvariant().Replace(".", "-").Replace("_", "-")
    while ($normalized.Contains("--")) {
        $normalized = $normalized.Replace("--", "-")
    }
    $tokens = @($normalized.Split(
        "-",
        [System.StringSplitOptions]::RemoveEmptyEntries))
    foreach ($blockedToken in @(
        "shell",
        "exec",
        "execute",
        "mcp",
        "command"
    )) {
        Assert-True (
            $tokens -cnotcontains $blockedToken
        ) "$Location contains executable vocabulary '$blockedToken'."
    }
    Assert-True (
        $normalized -cne "adb"
    ) "$Location cannot advertise a generic ADB identifier."
    foreach ($blockedSequence in @(
        "raw-shell",
        "raw-adb",
        "generic-adb",
        "adb-args",
        "adb-command",
        "run-adb",
        "execute-command",
        "mcp-execute",
        "arbitrary-command",
        "raw-args"
    )) {
        Assert-True (
            $normalized -cnotmatch
            "(^|-)$([regex]::Escape($blockedSequence))($|-)"
        ) "$Location contains executable vocabulary '$blockedSequence'."
    }
    if ($tokens -ccontains "adb") {
        Assert-True (
            $normalized -cmatch "(^|-)(wifi-adb|wireless-adb)($|-)"
        ) "$Location contains ADB outside a bounded Wi-Fi or wireless-ADB context."
    }
}

function Assert-ProviderCapabilityDiscovery {
    param(
        [object]$Value,
        [DateTimeOffset]$Now
    )

    Assert-ExactProperties -Value $Value -Expected @(
        "schema",
        "provider",
        "placement",
        "availability",
        "description_authentication",
        "authorizes_execution",
        "target_specific",
        "capabilities",
        "exclusions"
    ) -Location "discovery"
    Assert-True (
        ($Value.schema -is [string]) -and
        $Value.schema -ceq "rusty.quest.workflow.provider_capability_discovery.v1"
    ) "Unexpected discovery schema."

    Assert-ExactProperties -Value $Value.provider -Expected @(
        "id",
        "version"
    ) -Location "discovery.provider"
    Assert-True (
        ($Value.provider.id -is [string]) -and
        ([string]$Value.provider.id -cmatch "^[a-z0-9][a-z0-9._-]{1,158}[a-z0-9]$")
    ) "Discovery provider ID is invalid."
    Assert-SafeDiscoveryIdentifier `
        -Value ([string]$Value.provider.id) `
        -Location "discovery.provider.id"
    Assert-True (
        ($Value.provider.version -is [string]) -and
        ([string]$Value.provider.version -cmatch "^[0-9]+\.[0-9]+\.[0-9]+(?:-[a-z0-9.-]+)?$") -and
        ([string]$Value.provider.version).Length -le 64
    ) "Discovery provider version is invalid."

    $placements = @(
        "windows-host-process",
        "host-cli",
        "quest-application",
        "managed-service"
    )
    Assert-True (
        ($Value.placement -is [string]) -and
        $placements -ccontains [string]$Value.placement
    ) "Discovery placement is invalid."

    Assert-ExactProperties -Value $Value.availability -Expected @(
        "status",
        "observed_at_utc",
        "expires_at_utc",
        "maximum_age_seconds"
    ) -Location "discovery.availability"
    Assert-True (
        ($Value.availability.status -is [string]) -and
        @("descriptor-available", "unavailable", "disabled") -ccontains
        [string]$Value.availability.status
    ) "Discovery availability status is invalid."
    Assert-True (
        $Value.availability.observed_at_utc -is [string]
    ) "Discovery observation timestamp must be a string."
    Assert-True (
        $Value.availability.expires_at_utc -is [string]
    ) "Discovery expiry timestamp must be a string."
    $rfc3339DateTimePattern =
        "^[0-9]{4}-(?:0[1-9]|1[0-2])-" +
        "(?:0[1-9]|[12][0-9]|3[01])[Tt]" +
        "(?:[01][0-9]|2[0-3]):[0-5][0-9]:" +
        "(?:[0-5][0-9]|60)(?:\.[0-9]+)?" +
        "(?:[Zz]|[+-](?:[01][0-9]|2[0-3]):[0-5][0-9])$"
    Assert-True (
        [string]$Value.availability.observed_at_utc -cmatch
        $rfc3339DateTimePattern
    ) "Discovery observation timestamp must use RFC3339 date-time syntax."
    Assert-True (
        [string]$Value.availability.expires_at_utc -cmatch
        $rfc3339DateTimePattern
    ) "Discovery expiry timestamp must use RFC3339 date-time syntax."
    $observedAt = [DateTimeOffset]::MinValue
    $expiresAt = [DateTimeOffset]::MinValue
    Assert-True (
        [DateTimeOffset]::TryParse(
            [string]$Value.availability.observed_at_utc,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind,
            [ref]$observedAt)
    ) "Discovery observation timestamp is invalid."
    Assert-True (
        [DateTimeOffset]::TryParse(
            [string]$Value.availability.expires_at_utc,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind,
            [ref]$expiresAt)
    ) "Discovery expiry timestamp is invalid."
    $maximumAge = $Value.availability.maximum_age_seconds
    $maximumAgeIsNumber =
        $maximumAge -is [byte] -or
        $maximumAge -is [sbyte] -or
        $maximumAge -is [short] -or
        $maximumAge -is [ushort] -or
        $maximumAge -is [int] -or
        $maximumAge -is [uint] -or
        $maximumAge -is [long] -or
        $maximumAge -is [ulong] -or
        $maximumAge -is [float] -or
        $maximumAge -is [double] -or
        $maximumAge -is [decimal]
    $maximumAgeDecimal =
        if ($maximumAgeIsNumber) { [decimal]$maximumAge } else { -1 }
    Assert-True (
        $maximumAgeIsNumber -and
        [decimal]::Truncate($maximumAgeDecimal) -eq $maximumAgeDecimal -and
        $maximumAgeDecimal -ge 1 -and
        $maximumAgeDecimal -le 600
    ) "Discovery maximum age is invalid."
    $maximumAgeSeconds = [long]$maximumAgeDecimal
    Assert-True ($observedAt -le $Now) "Discovery observation is in the future."
    Assert-True ($expiresAt -gt $Now) "Discovery descriptor is stale."
    Assert-True ($expiresAt -gt $observedAt) "Discovery expiry must follow observation."
    $expectedFreshnessTicks =
        $maximumAgeSeconds * [TimeSpan]::TicksPerSecond
    Assert-True (
        ($expiresAt - $observedAt).Ticks -eq $expectedFreshnessTicks
    ) "Discovery freshness window is inconsistent."

    Assert-True (
        ($Value.description_authentication -is [string]) -and
        $Value.description_authentication -ceq "none"
    ) "Discovery description authentication must be none."
    Assert-True (
        ($Value.authorizes_execution -is [bool]) -and
        $Value.authorizes_execution -eq $false
    ) "Discovery must not authorize execution."
    Assert-True (
        ($Value.target_specific -is [bool]) -and
        $Value.target_specific -eq $false
    ) "Discovery must be target-free."

    Assert-JsonArray `
        -Value $Value.capabilities `
        -Location "discovery.capabilities"
    $capabilities = @($Value.capabilities)
    Assert-True (
        $capabilities.Count -ge 1 -and $capabilities.Count -le 64
    ) "Discovery capability count is invalid."
    $capabilityIds = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal)
    $authenticationRequirements = @(
        "none",
        "process-access-control",
        "caller-authority-external",
        "exact-target-binding",
        "current-identity-revision",
        "effect-owner-profile",
        "owner-session-grant",
        "wearer-approval",
        "ownership-generation"
    )
    foreach ($capability in $capabilities) {
        Assert-ExactProperties -Value $capability -Expected @(
            "id",
            "contract_versions",
            "actions",
            "effect_owner",
            "receipt_schema",
            "exclusions"
        ) -Location "discovery.capability"
        Assert-True (
            ($capability.id -is [string]) -and
            ([string]$capability.id -cmatch "^[a-z0-9][a-z0-9._-]{1,158}[a-z0-9]$") -and
            $capabilityIds.Add([string]$capability.id)
        ) "Discovery capability ID is invalid or duplicated."
        Assert-SafeDiscoveryIdentifier `
            -Value ([string]$capability.id) `
            -Location "discovery.capability.id"
        Assert-JsonArray `
            -Value $capability.contract_versions `
            -Location "discovery.capability.contract_versions"
        Assert-BoundedStringArray `
            -Values @($capability.contract_versions) `
            -Minimum 1 `
            -Maximum 8 `
            -Pattern "^[a-z0-9][a-z0-9._-]{1,190}[a-z0-9]$" `
            -Location "discovery.capability.contract_versions"
        foreach ($contractVersion in @($capability.contract_versions)) {
            Assert-SafeDiscoveryIdentifier `
                -Value ([string]$contractVersion) `
                -Location "discovery.capability.contract_versions"
        }
        Assert-True (
            ($capability.effect_owner -is [string]) -and
            [string]$capability.effect_owner -cmatch
            "^[a-z0-9][a-z0-9._-]{1,158}[a-z0-9]$"
        ) "Discovery effect owner is invalid."
        Assert-SafeDiscoveryIdentifier `
            -Value ([string]$capability.effect_owner) `
            -Location "discovery.capability.effect_owner"
        Assert-True (
            ($capability.receipt_schema -is [string]) -and
            [string]$capability.receipt_schema -cmatch
            "^[a-z0-9][a-z0-9._-]{1,190}[a-z0-9]$"
        ) "Discovery receipt schema is invalid."
        Assert-SafeDiscoveryIdentifier `
            -Value ([string]$capability.receipt_schema) `
            -Location "discovery.capability.receipt_schema"
        Assert-JsonArray `
            -Value $capability.exclusions `
            -Location "discovery.capability.exclusions"
        Assert-BoundedStringArray `
            -Values @($capability.exclusions) `
            -Minimum 1 `
            -Maximum 32 `
            -Pattern "^[a-z0-9][a-z0-9.-]{1,126}[a-z0-9]$" `
            -Location "discovery.capability.exclusions"

        Assert-JsonArray `
            -Value $capability.actions `
            -Location "discovery.capability.actions"
        $actions = @($capability.actions)
        Assert-True (
            $actions.Count -ge 1 -and $actions.Count -le 64
        ) "Discovery action count is invalid."
        $actionIds = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::Ordinal)
        foreach ($action in $actions) {
            Assert-ExactProperties -Value $action -Expected @(
                "id",
                "kind",
                "authentication_requirements"
            ) -Location "discovery.capability.action"
            Assert-True (
                ($action.id -is [string]) -and
                ([string]$action.id -cmatch "^[A-Za-z0-9][A-Za-z0-9._-]{1,94}[A-Za-z0-9]$") -and
                $actionIds.Add([string]$action.id)
            ) "Discovery action ID is invalid or duplicated."
            Assert-SafeDiscoveryIdentifier `
                -Value ([string]$action.id) `
                -Location "discovery.capability.action.id"
            Assert-True (
                ($action.kind -is [string]) -and
                @("observe", "effect", "cleanup") -ccontains
                [string]$action.kind
            ) "Discovery action kind is invalid."
            Assert-JsonArray `
                -Value $action.authentication_requirements `
                -Location "discovery.capability.action.authentication_requirements"
            Assert-BoundedStringArray `
                -Values @($action.authentication_requirements) `
                -Minimum 1 `
                -Maximum 8 `
                -Pattern "^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$" `
                -Location "discovery.capability.action.authentication_requirements"
            foreach ($requirement in @($action.authentication_requirements)) {
                Assert-True (
                    $authenticationRequirements -ccontains [string]$requirement
                ) "Discovery authentication requirement is unknown."
            }
            Assert-True (
                (@($action.authentication_requirements) -cnotcontains "none") -or
                @($action.authentication_requirements).Count -eq 1
            ) "Discovery authentication 'none' cannot be combined with another requirement."
        }
    }
    Assert-JsonArray `
        -Value $Value.exclusions `
        -Location "discovery.exclusions"
    Assert-BoundedStringArray `
        -Values @($Value.exclusions) `
        -Minimum 1 `
        -Maximum 32 `
        -Pattern "^[a-z0-9][a-z0-9.-]{1,126}[a-z0-9]$" `
        -Location "discovery.exclusions"

    $discoveryForbiddenNames = @(
        "adb",
        "agent_board",
        "approval",
        "args",
        "arguments",
        "command",
        "credential",
        "credentials",
        "device",
        "device_serial",
        "endpoint",
        "executable",
        "invocation",
        "lease",
        "local_path",
        "mcp",
        "path",
        "resolver",
        "serial",
        "shell",
        "target",
        "target_serial",
        "uri",
        "url"
    )
    $pending = [System.Collections.Generic.Stack[object]]::new()
    $pending.Push($Value)
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        if ($current -is [pscustomobject]) {
            foreach ($property in $current.PSObject.Properties) {
                Assert-True (
                    $discoveryForbiddenNames -cnotcontains
                    ([string]$property.Name).ToLowerInvariant()
                ) "Discovery contains forbidden property '$($property.Name)'."
                if ($null -ne $property.Value) {
                    $pending.Push($property.Value)
                }
            }
        }
        elseif (
            ($current -is [System.Collections.IEnumerable]) -and
            -not ($current -is [string])
        ) {
            foreach ($item in $current) {
                if ($null -ne $item) {
                    $pending.Push($item)
                }
            }
        }
    }
}

function Copy-JsonValue {
    param([object]$Value)
    return $Value |
        ConvertTo-Json -Depth 100 |
        ConvertFrom-Json -Depth 100 -DateKind String
}

function Assert-DiscoveryRejected {
    param(
        [string]$Case,
        [object]$Value,
        [DateTimeOffset]$Now
    )

    $rejected = $false
    try {
        Assert-ProviderCapabilityDiscovery -Value $Value -Now $Now
    }
    catch {
        $rejected = $true
    }
    Assert-True $rejected "Damaged discovery case '$Case' was accepted."
}

foreach ($schemaName in $requiredSchemas) {
    $path = Join-Path $schemaDirectory $schemaName
    Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing schema: $schemaName"
    Get-Content -Raw -LiteralPath $path |
        ConvertFrom-Json -Depth 100 -DateKind String |
        Out-Null
}

$intent = Get-Content -Raw -LiteralPath $intentPath |
    ConvertFrom-Json -Depth 100 -DateKind String
$wrapper = Get-Content -Raw -LiteralPath $wrapperPath |
    ConvertFrom-Json -Depth 100 -DateKind String
$discovery = Get-Content -Raw -LiteralPath $discoveryPath |
    ConvertFrom-Json -Depth 100 -DateKind String

Assert-True ($intent.schema -ceq "rusty.quest.workflow.intent.v1") "Unexpected intent schema."
Assert-True ($intent.constraints.exact_target_required -eq $true) "Portable intents must require an exact private target resolution."
Assert-True ($intent.PSObject.Properties.Name -notcontains "serial") "Portable intent leaked a serial."
Assert-True ($intent.PSObject.Properties.Name -notcontains "path") "Portable intent leaked a path."
Assert-True ($wrapper.schema -ceq "rusty.quest.workflow.evidence_wrapper.v1") "Unexpected wrapper schema."
Assert-True ($wrapper.provider_evidence_sha256 -cmatch "^[a-f0-9]{64}$") "Invalid owner-evidence digest."

Test-ForbiddenProperty -Value $intent -Location "intent"
Test-ForbiddenProperty -Value $wrapper -Location "wrapper"

$discoveryNow = [DateTimeOffset]::Parse(
    "2026-07-27T10:02:00Z",
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::RoundtripKind)
Assert-ProviderCapabilityDiscovery -Value $discovery -Now $discoveryNow

$unknownField = Copy-JsonValue $discovery
$unknownField.PSObject.Properties.Add(
    [psnoteproperty]::new("unexpected", "value"))
Assert-DiscoveryRejected "unknown-field" $unknownField $discoveryNow

$stale = Copy-JsonValue $discovery
$stale.availability.expires_at_utc = "2026-07-27T10:01:00.0000000Z"
$stale.availability.maximum_age_seconds = 60
Assert-DiscoveryRejected "stale" $stale $discoveryNow

$overlong = Copy-JsonValue $discovery
$overlong.availability.expires_at_utc = "2026-07-27T10:10:01.0000000Z"
$overlong.availability.maximum_age_seconds = 601
Assert-DiscoveryRejected "over-600-seconds" $overlong $discoveryNow

$integralJsonNumber = Copy-JsonValue $discovery
$integralJsonNumber.availability.maximum_age_seconds = [double]300
Assert-ProviderCapabilityDiscovery `
    -Value $integralJsonNumber `
    -Now $discoveryNow

$fractionalJsonNumber = Copy-JsonValue $discovery
$fractionalJsonNumber.availability.maximum_age_seconds = [double]300.5
Assert-DiscoveryRejected `
    "fractional-maximum-age" `
    $fractionalJsonNumber `
    $discoveryNow

$futureObservation = Copy-JsonValue $discovery
$futureObservation.availability.observed_at_utc =
    "2026-07-27T10:02:01.0000000Z"
$futureObservation.availability.expires_at_utc =
    "2026-07-27T10:07:01.0000000Z"
Assert-DiscoveryRejected "future-observation" $futureObservation $discoveryNow

$subMillisecondMismatch = Copy-JsonValue $discovery
$subMillisecondMismatch.availability.expires_at_utc =
    "2026-07-27T10:05:00.0000001Z"
Assert-DiscoveryRejected `
    "sub-millisecond-freshness-mismatch" `
    $subMillisecondMismatch `
    $discoveryNow

$rfc3339WithoutFraction = Copy-JsonValue $discovery
$rfc3339WithoutFraction.availability.observed_at_utc =
    "2026-07-27T10:00:00Z"
$rfc3339WithoutFraction.availability.expires_at_utc =
    "2026-07-27T10:05:00Z"
Assert-ProviderCapabilityDiscovery `
    -Value $rfc3339WithoutFraction `
    -Now $discoveryNow

$rfc3339WithOffset = Copy-JsonValue $discovery
$rfc3339WithOffset.availability.observed_at_utc =
    "2026-07-27T12:00:00.1234567+02:00"
$rfc3339WithOffset.availability.expires_at_utc =
    "2026-07-27T12:05:00.1234567+02:00"
Assert-ProviderCapabilityDiscovery `
    -Value $rfc3339WithOffset `
    -Now $discoveryNow

$timestampWithSpace = Copy-JsonValue $discovery
$timestampWithSpace.availability.observed_at_utc =
    "2026-07-27 10:00:00Z"
Assert-DiscoveryRejected `
    "non-rfc3339-space-separator" `
    $timestampWithSpace `
    $discoveryNow

$timestampWithoutZone = Copy-JsonValue $discovery
$timestampWithoutZone.availability.observed_at_utc =
    "2026-07-27T10:00:00"
Assert-DiscoveryRejected `
    "non-rfc3339-missing-zone" `
    $timestampWithoutZone `
    $discoveryNow

$timestampWithCompactOffset = Copy-JsonValue $discovery
$timestampWithCompactOffset.availability.observed_at_utc =
    "2026-07-27T12:00:00+0200"
Assert-DiscoveryRejected `
    "non-rfc3339-compact-offset" `
    $timestampWithCompactOffset `
    $discoveryNow

$duplicateCapability = Copy-JsonValue $discovery
$duplicateCapability.capabilities = @($duplicateCapability.capabilities) +
    @(Copy-JsonValue $duplicateCapability.capabilities[0])
Assert-DiscoveryRejected "duplicate-capability" $duplicateCapability $discoveryNow

$duplicateAction = Copy-JsonValue $discovery
$duplicateAction.capabilities[0].actions =
    @($duplicateAction.capabilities[0].actions) +
    @(Copy-JsonValue $duplicateAction.capabilities[0].actions[0])
Assert-DiscoveryRejected "duplicate-action" $duplicateAction $discoveryNow

$sensitive = Copy-JsonValue $discovery
$sensitive.PSObject.Properties.Add(
    [psnoteproperty]::new("endpoint", "loopback"))
Assert-DiscoveryRejected "sensitive-property" $sensitive $discoveryNow

$invocation = Copy-JsonValue $discovery
$invocation.PSObject.Properties.Add(
    [psnoteproperty]::new("invocation", "provider --describe"))
Assert-DiscoveryRejected "executable-invocation" $invocation $discoveryNow

$authorizing = Copy-JsonValue $discovery
$authorizing.authorizes_execution = $true
Assert-DiscoveryRejected "authorizes-execution" $authorizing $discoveryNow

$legitimateWirelessAdb = Copy-JsonValue $discovery
$legitimateWirelessAdb.capabilities[0].actions[0].id =
    "request-wireless-adb"
Assert-ProviderCapabilityDiscovery `
    -Value $legitimateWirelessAdb `
    -Now $discoveryNow

$legitimateWifiAdb = Copy-JsonValue $discovery
$legitimateWifiAdb.capabilities[0].actions[0].id = "wifi-adb"
Assert-ProviderCapabilityDiscovery `
    -Value $legitimateWifiAdb `
    -Now $discoveryNow

$legitimateWirelessAdbContext = Copy-JsonValue $discovery
$legitimateWirelessAdbContext.capabilities[0].actions[0].id =
    "wireless-adb"
Assert-ProviderCapabilityDiscovery `
    -Value $legitimateWirelessAdbContext `
    -Now $discoveryNow

$twoCharacterAction = Copy-JsonValue $discovery
$twoCharacterAction.capabilities[0].actions[0].id = "go"
Assert-DiscoveryRejected `
    "structural-two-character-action" `
    $twoCharacterAction `
    $discoveryNow

$exactShell = Copy-JsonValue $discovery
$exactShell.provider.id = "shell"
Assert-DiscoveryRejected "identifier-exact-shell" $exactShell $discoveryNow

$segmentShell = Copy-JsonValue $discovery
$segmentShell.capabilities[0].id = "example.quest.raw-shell"
Assert-DiscoveryRejected "identifier-segment-shell" $segmentShell $discoveryNow

$genericAdb = Copy-JsonValue $discovery
$genericAdb.capabilities[0].contract_versions[0] = "adb"
Assert-DiscoveryRejected "identifier-generic-adb" $genericAdb $discoveryNow

$genericCommand = Copy-JsonValue $discovery
$genericCommand.capabilities[0].actions[0].id = "command"
Assert-DiscoveryRejected `
    "identifier-generic-command" `
    $genericCommand `
    $discoveryNow

$genericCommandToken = Copy-JsonValue $discovery
$genericCommandToken.capabilities[0].actions[0].id = "generic-command"
Assert-DiscoveryRejected `
    "identifier-generic-command-token" `
    $genericCommandToken `
    $discoveryNow

$rawCommandToken = Copy-JsonValue $discovery
$rawCommandToken.capabilities[0].actions[0].id = "raw-command"
Assert-DiscoveryRejected `
    "identifier-raw-command-token" `
    $rawCommandToken `
    $discoveryNow

$commandWirelessAdb = Copy-JsonValue $discovery
$commandWirelessAdb.capabilities[0].actions[0].id =
    "command-wireless-adb"
Assert-DiscoveryRejected `
    "identifier-command-wireless-adb" `
    $commandWirelessAdb `
    $discoveryNow

$adbCommand = Copy-JsonValue $discovery
$adbCommand.capabilities[0].actions[0].id = "adb-command"
Assert-DiscoveryRejected "identifier-adb-command" $adbCommand $discoveryNow

$runAdb = Copy-JsonValue $discovery
$runAdb.capabilities[0].actions[0].id = "run-adb"
Assert-DiscoveryRejected "identifier-run-adb" $runAdb $discoveryNow

$dangerousEffectOwner = Copy-JsonValue $discovery
$dangerousEffectOwner.capabilities[0].effect_owner =
    "example.quest.execute-command"
Assert-DiscoveryRejected `
    "identifier-effect-owner" `
    $dangerousEffectOwner `
    $discoveryNow

$exactExec = Copy-JsonValue $discovery
$exactExec.capabilities[0].actions[0].id = "exec"
Assert-DiscoveryRejected "identifier-exec" $exactExec $discoveryNow

$exactExecute = Copy-JsonValue $discovery
$exactExecute.capabilities[0].actions[0].id = "execute"
Assert-DiscoveryRejected "identifier-execute" $exactExecute $discoveryNow

$executeCommand = Copy-JsonValue $discovery
$executeCommand.capabilities[0].receipt_schema =
    "example.quest.execute-command.receipt.v1"
Assert-DiscoveryRejected `
    "identifier-execute-command" `
    $executeCommand `
    $discoveryNow

$exactMcp = Copy-JsonValue $discovery
$exactMcp.capabilities[0].actions[0].id = "mcp"
Assert-DiscoveryRejected "identifier-mcp" $exactMcp $discoveryNow

$mcpExecute = Copy-JsonValue $discovery
$mcpExecute.capabilities[0].actions[0].id = "mcp-execute"
Assert-DiscoveryRejected "identifier-mcp-execute" $mcpExecute $discoveryNow

$arbitraryCommand = Copy-JsonValue $discovery
$arbitraryCommand.capabilities[0].actions[0].id = "arbitrary-command"
Assert-DiscoveryRejected `
    "identifier-arbitrary-command" `
    $arbitraryCommand `
    $discoveryNow

$rawArgs = Copy-JsonValue $discovery
$rawArgs.capabilities[0].actions[0].id = "raw-args"
Assert-DiscoveryRejected "identifier-raw-args" $rawArgs $discoveryNow

if (-not [string]::IsNullOrWhiteSpace($ProviderDiscoveryPath)) {
    $resolvedDiscoveryPath = (
        Resolve-Path -LiteralPath $ProviderDiscoveryPath -ErrorAction Stop
    ).Path
    $candidateDiscovery = Get-Content -Raw -LiteralPath $resolvedDiscoveryPath |
        ConvertFrom-Json -Depth 100 -DateKind String
    if ([string]::IsNullOrWhiteSpace($ValidationNowUtc)) {
        $candidateNow = [DateTimeOffset]::UtcNow
    }
    else {
        $candidateNow = [DateTimeOffset]::MinValue
        Assert-True (
            [DateTimeOffset]::TryParseExact(
                $ValidationNowUtc,
                "O",
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None,
                [ref]$candidateNow)
        ) "ValidationNowUtc must use the round-trip UTC timestamp format."
        Assert-True (
            $candidateNow.Offset -eq [TimeSpan]::Zero
        ) "ValidationNowUtc must be UTC."
    }
    Assert-ProviderCapabilityDiscovery `
        -Value $candidateDiscovery `
        -Now $candidateNow
    Write-Host (
        "Provider discovery semantic validation passed for " +
        $resolvedDiscoveryPath)
}
elseif (-not [string]::IsNullOrWhiteSpace($ValidationNowUtc)) {
    throw "ValidationNowUtc requires ProviderDiscoveryPath."
}

if ([string]::IsNullOrWhiteSpace($ProviderDiscoveryPath)) {
    $entrypointNow = "2026-07-27T10:02:00.0000000Z"
    $validArguments = @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        $PSCommandPath,
        "-Root",
        $resolvedRoot,
        "-ProviderDiscoveryPath",
        $discoveryPath,
        "-ValidationNowUtc",
        $entrypointNow
    )
    $previousNativePreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    $temporaryDescriptorPath = [IO.Path]::GetTempFileName()
    try {
        $validOutput = @(& pwsh @validArguments 2>&1)
        Assert-True ($LASTEXITCODE -eq 0) "Descriptor validation entrypoint rejected a valid descriptor."
        Assert-True (
            ($validOutput -join "`n") -match
            "Provider discovery semantic validation passed"
        ) "Descriptor validation entrypoint did not report semantic validation."

        $currentDescriptor = Copy-JsonValue $discovery
        $currentObservedAt = [DateTimeOffset]::UtcNow.AddSeconds(-1)
        $currentDescriptor.availability.observed_at_utc =
            $currentObservedAt.ToString("O")
        $currentDescriptor.availability.expires_at_utc =
            $currentObservedAt.AddSeconds(300).ToString("O")
        [IO.File]::WriteAllText(
            $temporaryDescriptorPath,
            ($currentDescriptor | ConvertTo-Json -Depth 100) + "`n",
            [Text.UTF8Encoding]::new($false))
        $currentArguments = @(
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            $PSCommandPath,
            "-Root",
            $resolvedRoot,
            "-ProviderDiscoveryPath",
            $temporaryDescriptorPath
        )
        $currentOutput = @(& pwsh @currentArguments 2>&1)
        Assert-True (
            $LASTEXITCODE -eq 0
        ) "Descriptor validation entrypoint rejected a currently fresh descriptor."

        $entrypointDamaged = Copy-JsonValue $currentDescriptor
        $entrypointDamaged.authorizes_execution = $true
        [IO.File]::WriteAllText(
            $temporaryDescriptorPath,
            ($entrypointDamaged | ConvertTo-Json -Depth 100) + "`n",
            [Text.UTF8Encoding]::new($false))
        $invalidArguments = @(
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            $PSCommandPath,
            "-Root",
            $resolvedRoot,
            "-ProviderDiscoveryPath",
            $temporaryDescriptorPath
        )
        $invalidOutput = @(& pwsh @invalidArguments 2>&1)
        Assert-True (
            $LASTEXITCODE -ne 0
        ) "Descriptor validation entrypoint accepted a damaged descriptor."
    }
    finally {
        $PSNativeCommandUseErrorActionPreference = $previousNativePreference
        Remove-Item -LiteralPath $temporaryDescriptorPath -Force -ErrorAction SilentlyContinue
    }
}

$rawFallbackAllowedClaims = @("transport-observed", "diagnostic-only")
Assert-True ($rawFallbackAllowedClaims -notcontains "owner-effect-confirmed") "Raw fallback must not claim an owner effect."

Write-Host "Agent execution contract check passed for $resolvedRoot"
