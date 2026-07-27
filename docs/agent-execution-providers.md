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

The portable intent and wrapper schemas live under `schemas/`. They are
workflow records, not executable provider requests.

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
2. Discover provider capabilities without mutating a device.
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
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-public-safe.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-rusty-morphospace-routing.ps1
```
