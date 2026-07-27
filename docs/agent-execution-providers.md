# Agent Execution Providers

Use an owning application for repeatable Quest operations when it exposes a
closed, typed command with exact-target validation and fresh readback. Keep
this workflow as the provider selector, evidence wrapper, troubleshooting
guide, and raw-diagnostic fallback.

## Decision

Choose a provider per operation, not once for an entire run:

| Operation | Preferred provider | Required confirmation |
| --- | --- | --- |
| Inspect an APK, install it on one ADB-authorized headset, resolve its launcher, or collect bounded package/foreground/process state | QuestIonAble File Manager typed CLI or local API | Artifact digest and identity, exact current target, installed package/version/signer readback, and operation-specific state |
| Execute an approved operation across managed enrolled headsets | Rusty Fleet | Immutable target snapshot, current Manifold decision/lease/revision, effect-owner receipt, and separate cleanup |
| Prove OpenXR, Spatial SDK, renderer, source, or app-owned effective state | The participating Quest app | App-owned current-run receipt or marker |
| Search or control Kiosk-owned catalog/foreground behavior | Rusty Kiosk through its bounded provider or Fleet adapter | Kiosk-owned receipt and effective state |
| Inspect Meta tooling state, capture, or performance evidence | Meta Horizon MCP, Meta VR CLI, or `hzdb` | Provider-specific readback and artifact provenance |
| Investigate a missing provider feature or recover a broken development route | Explicit serial-scoped ADB fallback | Transport facts only, unless an owning consumer independently confirms the effect |

Provider availability is not authority. A discovered executable, device, app,
or adapter is inert until the operation's exact target, approval, and
owner-specific authority checks pass.

## Inert Capability Discovery

An owner may project its existing typed registry through
`rusty.quest.workflow.provider_capability_discovery.v1`. The short-lived
descriptor identifies the provider and version, placement, descriptor
availability, typed capabilities and actions, accepted contract versions,
authentication requirements, effect owner, receipt schema, and exclusions.

Discovery is target-free and authorizes nothing. It contains no invocation,
executable or artifact location, device identity, resolver, endpoint,
credential, approval, coordination record, raw arguments, shell, or MCP
execution surface. The descriptor does not probe a backend or activate a
capability. `descriptor-available` means only that the provider described its
registry; it does not prove that a target, platform dependency, effect-owner
profile, wearer approval, or caller authority is available.

Ordinary JSON Schema validation is structural. Required semantic validation
also enforces unique capability and action IDs, `observed_at_utc` not later
than the validation clock, expiry after observation, exact correspondence
between the timestamp interval and `maximum_age_seconds` at exact
100-nanosecond `TimeSpan` tick precision, a maximum 600-second window, current
freshness, and rejection of executable vocabulary in provider, capability,
contract, effect-owner, receipt, and action identifiers. `command` is rejected
as an identifier token, including forms such as `generic-command`,
`raw-command`, and `command-wireless-adb`. Exact generic `adb`, `adb-command`,
`run-adb`, shell, exec/execute, MCP, arbitrary-command, and raw-argument forms
are also rejected. Bounded typed Wi-Fi contexts such as
`request-wireless-adb`, `wifi-adb`, and `wireless-adb` remain valid because
they name one connectivity capability rather than expose generic ADB commands
or arguments. Timestamp fields must first match RFC3339 date-time syntax,
including an explicit `Z` or numeric offset through `+23:59` or `-23:59`,
before being normalized to an instant for freshness evaluation. Consumers must
not narrow that schema range to the platform-specific `DateTimeOffset`
constructor limit of 14 offset hours. RFC3339 leap-second timestamps using
second `60` are normalized to the following second before the numeric offset
is applied; second `61` is invalid.

Consumers must:

1. reject unknown properties and unsupported descriptor schemas;
2. reject duplicate capability or action IDs;
3. reject an observation from the future, an expired descriptor, or a
   freshness window longer than 600 seconds;
4. match one advertised capability, action, and contract version exactly;
5. satisfy every advertised authentication requirement through the real
   owner before constructing an owner-specific request;
6. preserve the descriptor as description only and obtain a separate
   operation approval, target binding, authority decision, and owner receipt.

The public example is illustrative. It is not an installed provider,
activation record, health result, or permission to execute.

## Contract Separation

Do not use one executable operation manifest for both local ADB and managed
Fleet work.

1. A portable workflow intent can describe the goal and required capabilities.
   It contains no serial, alias, local path, endpoint, credential, target
   selection, approval, or Manifold field.
2. A private local resolver binds machine paths, alias-to-serial mappings,
   tool identity, observed package/signer facts, and optional resource-
   coordination correlation.
3. A File Manager operation binds one exact current serial, one inspected
   artifact digest, one-use operation identity, closed install/launch policy,
   local approval, fresh readback, and cleanup.
4. A Fleet operation binds an immutable Fleet target snapshot, current
   Manifold decision/lease/revision/epoch/revocation state, authenticated
   effect-owner delivery, owner receipts, and separate terminal cleanup.
5. The portable workflow wrapper records only the owner schema, evidence hash,
   sanitized result, claim class, and limitations. It never augments or
   relabels the owner-issued evidence.

The portable intent, inert discovery, and wrapper schemas live under
`schemas/`. They are workflow records, not executable provider requests.

## Typed Surface Before MCP

Maintain one typed command registry in each owning application and project it
to its CLI, local API, and human UI. Add MCP only after those projections have
stable conformance tests.

A future MCP surface may expose:

- capability discovery;
- preflight for one typed operation;
- explicitly approved typed execution;
- status and cancellation.

It must not expose raw shell, `adb(args[])`, arbitrary Android components or
intents, arbitrary paths, properties, process commands, caller-supplied
authority labels, or credentials.

## Provider Selection

For every operation:

1. State the goal and evidence needed.
2. Discover provider capabilities without mutating a device and reject stale
   descriptors.
3. Select the narrowest owning provider that can produce the required
   confirmation.
4. Resolve private target and artifact inputs outside portable records.
5. Obtain the operation-specific approval and authority.
6. Execute one typed operation.
7. Preserve the owner evidence byte-for-byte and emit a sanitized hash-bound
   workflow wrapper.
8. If the provider cannot complete the operation, record the limitation before
   using a narrower diagnostic fallback.

Never present a raw ADB fallback result as accepted File Manager, Fleet,
Manifold, Kiosk, or app-owned evidence.

## Resource Coordination

Machine-local coordination can prevent agents from colliding on the same
headset, build output, or bridge port. A coordination lease is not device
identity, operator approval, app admission, or Manifold authority. Store any
coordination identifier only in private run evidence.

## Validation

Run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-AgentExecutionContracts.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-AgentExecutionContracts.ps1 -ProviderDiscoveryPath <descriptor.json>
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-public-safe.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-rusty-morphospace-routing.ps1
```

The first form runs repository conformance and damaged cases. The second also
applies the reusable semantic validator to the supplied descriptor using the
current UTC clock.
