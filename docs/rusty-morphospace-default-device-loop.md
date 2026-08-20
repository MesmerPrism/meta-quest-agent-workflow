# Rusty Morphospace Default Device Loop

Use this loop for routine Rusty Morphospace Quest builds, deployment, launch,
runtime validation, and cleanup. It deliberately exercises the ecosystem's
typed product surfaces while preserving the owning project, application, and
platform boundaries.

The loop is not a requirement to involve every product in every operation.
Choose the narrowest complete route:

| Run shape | Default product path |
| --- | --- |
| One local development headset | Project build/run capsule -> QuestIonAble File Manager -> Rusty Kiosk when catalog or launch control is needed -> app-owned evidence |
| Enrolled managed headset set | Project build/run capsule -> Rusty Fleet target snapshot and approved operation -> Rusty Kiosk or another effect owner -> app-owned evidence |
| Provider-gap diagnosis or recovery | The applicable product path -> recorded provider gap -> bounded Meta tool or serial-scoped ADB fallback |

Do not wrap a local File Manager request in a Fleet request merely to exercise
Fleet. Do not bypass Fleet with File Manager when managed policy, target-set
authority, or multi-headset coordination is part of the operation.

## Authority Split

| Concern | Owner |
| --- | --- |
| Source revision, build inputs, feature lock, runtime profile, and run capsule | Project and work-environment workflow |
| Package identity, signing, permissions, Android/OpenXR lifecycle, and effective runtime | Quest app shell or Rusty Quest |
| Local artifact inspection, exact-serial install, launcher resolution, and bounded Android observation | QuestIonAble File Manager |
| Catalog, selected app, normal or guarded launch, foreground guard, and Kiosk-owned effective state | Rusty Kiosk |
| Managed target selection, operator policy, current authority, coordinated dispatch, and fleet projection | Rusty Fleet with current Manifold and effect-owner authority |
| Renderer, source, session, frame, and app feature readiness | Participating application |
| Novel transport diagnosis and recovery | Meta tools or labeled raw ADB fallback |

File Manager, Fleet, and Kiosk are adapters and products around those owners;
none of them becomes build or application-runtime authority.

## 0. Choose And Complete The Build Lane

Before entering a device transaction, follow
[Quest APK Build Lanes](quest-apk-build-lanes.md). Use the warm iteration lane
for ordinary edits and the frozen Candidate/publication lane for handoff or
reproducibility claims.

Both lanes must hand this loop one exact, inspected, content-addressed APK and
run capsule. That device invariant does not require warm compiler intermediates
to be content-addressed and does not turn a live iteration checkout into a
clean-source claim. Do not acquire a headset merely to compile an APK.

## 1. Declare The Run

Before resolving a machine path or target, create or review:

- the declared project source observation and build lane, including exact
  clean revisions when the selected lane requires them;
- the selected feature lock and effective runtime input;
- the content-addressed APK and run capsule;
- a `rusty.quest.workflow.intent.v1` record for each materially different
  operation;
- the required claim and cleanup evidence.

For routine operations, set `constraints.raw_fallback_allowed` to `false`.
Enable it only for a named provider gap, novel diagnostic, or recovery step.
Portable intent contains no executable path, serial, alias, credential,
approval, coordination identifier, endpoint, or Fleet/Manifold state.

## 2. Resolve Providers Privately

Resolve the File Manager CLI, Fleet CLI or endpoint, target aliases, ADB path,
Kiosk pairing material, and local evidence roots from ignored machine
configuration. Verify the executable identity and obtain fresh, inert
capability descriptions where the owner supplies them.

Capability discovery describes a registry. It does not:

- select or probe a headset;
- approve an operation;
- establish Fleet or Manifold authority;
- prove Kiosk or application health;
- grant permission to fall back to a broader provider.

If the selected File Manager version does not expose the inspected deployment
routes, stop before install and record that version/capability mismatch.
When the machine-local work environment supplies a File Manager deployment
wrapper, prefer it over reconstructing a multi-step sequence. The wrapper must
resolve one exact provider hash and source revision, retain read-locked
content-addressed copies of both provider and APK for the whole device
transaction, and preserve each typed result in a private run directory. It may
not turn provider discovery into device authority.

## 3. Inspect And Install Locally

For a single development headset, use File Manager's inspected deployment
route:

```powershell
$FileManager = "<file-manager-cli>"

& $FileManager apk inspect `
  --file <path-to.apk> `
  --json

& $FileManager apk install `
  --serial <quest-serial> `
  --file <path-to.apk> `
  --json
```

The accepted local receipt must bind the exact retained artifact digest and
identity, exact serial, installed base APK hash and size, and fresh installed
state. An ADB exit code alone is not equivalent confirmation.

A machine-local wrapper may expose inspect-only, read-only observe,
install-only, and non-Kiosk deploy modes over these same closed routes. Install
or deploy must stop before launch when the mutation receipt is absent,
`pending`, failed, or does not repeat the exact inspected and installed byte
evidence. It must not resolve one executable and later run a different ambient
build from a repository output folder.

For a managed target set, do not translate these arguments into a Fleet
request. Use Fleet's current typed registry and bind:

- one immutable target snapshot;
- current policy and operator approval;
- current Manifold decision, lease, revision, epoch, and revocation state when
  required;
- the effect-owner request and receipt;
- terminal cleanup or reconciliation for each target.

## 4. Use Kiosk As The Launch Front Door

When the app participates in the Kiosk catalog or foreground-control workflow,
read Kiosk state before launch:

```powershell
& $FileManager kiosk status `
  --serial <quest-serial> `
  --json
```

Use Kiosk's typed command or authenticated direct provider for selection,
catalog refresh, normal launch, guarded launch, or return-to-Kiosk behavior.
For example, after the exact selected entry is confirmed:

```powershell
& $FileManager kiosk command `
  --serial <quest-serial> `
  --command <typed-kiosk-command> `
  --confirm-kiosk-control `
  --json
```

Preserve the Kiosk receipt and fresh effective state. File Manager transports
or projects the request; Kiosk retains catalog, launch, and watchdog authority.
Wearer-enabled Accessibility remains a separate diagnostic capability and
does not create HOME or device-owner authority.

If the app is intentionally outside Kiosk, use File Manager's resolved
launcher route instead:

```powershell
& $FileManager apk launch `
  --serial <quest-serial> `
  --file <path-to.apk> `
  --json
```

That exception is a declared launch shape, not a silent return to handcrafted
component strings.

## 5. Confirm Application Runtime

After launch, use File Manager for bounded Android state and the application
for runtime truth:

```powershell
& $FileManager apk observe `
  --serial <quest-serial> `
  --file <path-to.apk> `
  --json
```

File Manager may confirm matching installed bytes, foreground state, resumed
component, and process IDs. It does not prove OpenXR session state, renderer
frames, selected source, feature-lock adoption, or application settings.
Require the participating app's current-run marker or receipt for those facts.
Read-only observe remains useful when Home, Guardian, a lock screen, or another
system Activity prevents launch: matching installed bytes can pass while
foreground, resumed, and process facts honestly remain false. Record the
separate launch blocker instead of weakening either claim.

Treat Kiosk foreground readback, File Manager Android observation, and
app-owned readiness as separate evidence rows. A complete run may need all
three; none substitutes for another.

## 6. Collect Diagnostics Through The Narrowest Owner

Use, in order:

1. app-owned bounded diagnostics for application state;
2. File Manager or Kiosk typed status for their owned state;
3. Fleet status and effect-owner receipts for managed execution;
4. Meta Horizon MCP, Meta VR CLI, or `hzdb` for configured Quest diagnostics;
5. serial-scoped ADB only after the fallback gate below.

Capture only after app-owned readiness or an explicit diagnostic timing
boundary. Keep raw logs, screenshots, traces, serials, packages, private
profiles, and executable-resolution records outside public source.

## 7. Cleanup And Reconcile

Restore only state owned by the run:

- stop only the target app or Kiosk action covered by the run;
- restore exact prior runtime properties and device settings;
- remove only run-owned forwards and staged files;
- obtain File Manager, Kiosk, app, and Fleet cleanup readback as applicable;
- preserve partial or failed owner receipts for later reconciliation.

A Fleet run is not terminal until every target is terminal or explicitly
reconcilable. A local run is not clean merely because the target Activity left
the foreground.

## Raw Fallback Gate

Use direct ADB only when one of these is true:

- bootstrap is required before an owning product can operate;
- the owner advertises no capability for the exact goal;
- the typed operation failed and bounded transport diagnosis is needed;
- recovery of the owning route itself is the explicit task.

Before fallback, record:

- intended owner and version;
- missing or failed capability/action;
- exact goal and required claim;
- why the product receipt cannot currently be obtained;
- fallback scope, stop condition, and cleanup;
- the product improvement or diagnostic follow-up suggested by the gap.

Raw ADB may claim only transport observation or diagnostic evidence in the
workflow wrapper. It cannot be relabeled as File Manager, Fleet, Kiosk,
Manifold, or application acceptance.

## Improvement Feedback

The default loop is also a product-integration probe. Classify friction as:

| Finding | Route |
| --- | --- |
| Repeated manual argument or parsing step | Add or refine a closed typed command in the owning product |
| Ambient executable or artifact drift between typed steps | Resolve one exact hash, make run-owned read-locked copies, and bind every step to them |
| Missing exact-target or effective readback | Strengthen the owner's receipt before expanding automation |
| Local action incorrectly requires managed authority | Correct the File Manager/Fleet contract boundary |
| Managed action bypasses policy or effect-owner evidence | Correct Fleet/Manifold/effect-owner admission |
| Launch/catalog/guard state is ambiguous | Improve the Kiosk contract and readback |
| Runtime truth inferred from Android foreground state | Add an app-owned marker or receipt |

Do not normalize a provider gap by permanently embedding a raw command in the
workflow. Keep the fallback visible until the owning product route exists and
passes its own conformance tests.
