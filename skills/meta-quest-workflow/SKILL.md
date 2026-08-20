---
name: meta-quest-workflow
description: 'Use for Meta Quest device work through Rusty Morphospace File Manager, Kiosk, or Fleet defaults, with serial-scoped ADB fallback, APK validation, OpenXR/API-layer inspection, capture, diagnostics, sidecars, app-owned probes, and Meta tooling.'
---

# Meta Quest Workflow

Use this skill before touching a Meta Quest headset, ADB transport, APK
install/launch, screenshots, screenrecord, logcat, Perfetto, camera metadata,
MediaProjection, Wi-Fi ADB, OpenXR API layers, or Quest-specific MCP tooling.

This is a public, portable device-operation skill. It does not own application
composition, runtime features, command/session/stream authority, or a specific
headset, package, repository layout, resource-lock service, or MCP client.

## Rusty Morphospace Routing

For Rusty Morphospace work, read the repository's
`docs/rusty-morphospace-repo-routing.md`:

- this repository owns reusable device-operation procedure;
- `rusty-morphospace-work-environment` owns project composition, closed feature
  locks, workspace isolation, and workflow contracts;
- `rusty-quest` owns Quest/Android/OpenXR/Spatial SDK adapters, packaging,
  permissions, lifecycle, and effective-runtime receipts;
- `rusty-hostess` owns Windows CLI/API and WPF install, launch, capture,
  validation, cleanup, and evidence projection, including its opaque
  Meta/MQDH Cinematic presentation adapter;
- `rusty-fleet` owns the multi-headset Hub, Console, `fleetctl`, operator
  policy, enrollment/status projections, and no-ADB fleet monitoring; its Quest
  Fleet Agent producer remains in the Rusty Quest platform lane;
- `rusty-manifold` owns accepted command, session, stream, admission, and
  control-transport state;
- `rusty-lattice` owns tracked-space relations and poses; Matter and Optics own
  computational and renderer-neutral visual contracts.

Public Rusty XR is historical/compatibility provenance only. Do not introduce
new `rusty.xr.*`, `/rustyxr/...`, `RustyXr.*`, or Makepad-specific authority for
current work.

## Optional Local Work Environment

An installer may add
`references/local-work-environment.json` beside this skill. When present, use
it only to resolve the exact local `rusty-morphospace-work-environment` clone
and its portable project docs:

- `docs/QUEST_APK_WORKFLOW.md`
- `docs/PROJECT_ISOLATION.md`
- `docs/PUBLIC_PRIVATE_BOUNDARY.md`
- `docs/INSTRUCTION_SYNCHRONIZATION.md`

The generated locator is local installation metadata, not part of this
canonical skill and not device authority. It cannot override this repository's
device-operation procedure, select a target, authorize a mutation, or supply
credentials. If the locator is absent, use a repository explicitly named by
the user or ask for its location; never guess a machine path.

## Playbook Source Resolution

The installed skill is a portable router; repository-level playbooks are not
duplicated into the installation. In the canonical source checkout, use the
adjacent `README.md` and `docs/playbook-index.md` directly. Otherwise run:

```powershell
pwsh -NoProfile -File `
  .\scripts\Resolve-PlaybookSource.ps1 -Json
```

The resolver validates `.morphospace-skill-source.json` and, when present,
`references/local-meta-quest-playbooks.json`. Use a returned local source only
when `mode` is `local`; that means its repository, commit, Git tree, clean
status, and playbook paths all matched. If local validation fails, use the
returned `pinned-public` URLs. They are bound to the installed source commit,
never floating `main`.

The locator and resolver choose documentation bytes only. They do not select
a device or executable, authorize a mutation, or override an owning app's
command, receipt, or cleanup contract. See
`docs/local-playbook-resolution.md` in the source repository.

## First Read

Read only the playbooks needed for the task:

1. `README.md`
2. `docs/playbook-index.md` when choosing a focused playbook or locating an
   application-owned command, status, receipt, or cleanup contract
3. `docs/quest-apk-build-lanes.md` for APK iteration, cache invalidation,
   Candidate assembly, or build-timing work
4. `docs/rusty-morphospace-default-device-loop.md` for routine Rusty
   Morphospace build/deploy/launch/validate work
5. `docs/agent-execution-providers.md`
6. `docs/adb-basics.md` only for bootstrap, diagnostics, or fallback
7. `docs/apk-install-launch.md`
8. `docs/artifact-and-evidence-discipline.md`
9. `docs/quest-signal-patterns.md`
10. `docs/accessibility-foreground-watchdogs.md` for attended foreground
   monitoring, Meta Home transitions, or special Accessibility enablement
11. `docs/host-headset-mutation-confirmation.md` for state changes
12. `docs/managed-device-store-apps.md` for managed modes or Store apps
13. `docs/quest-capture-stack-notes.md` and
   `docs/capture-source-taxonomy.md` for capture tasks
14. `docs/quest-streaming-and-direct-link-gates.md` for Quest/Quest or
   Quest/PC streaming, direct links, and multi-layer promotion evidence
15. `docs/openxr-tracking-boundary.md` for native OpenXR bridges, API-layer
    inspection or interposition, bounded input synthesis, or Spatial SDK and
    OpenXR integration work
16. `docs/termux-linux-sidecars.md` when Termux or Wi-Fi ADB is involved
17. `docs/meta-horizon-mcp-and-hzdb.md` for Meta VR CLI/MCP or Meta XR Operator
18. `docs/meta-vr-cli-evidence-profiles.md` for pinned Meta health, bounded
    logcat, screenshot, or XR frame-pacing Perfetto evidence

When this skill is installed without the repo docs, use only the validated
local or commit-pinned public source returned by the resolver.

## Default Rusty Morphospace Ecosystem Loop

For routine work, use:

```text
project-owned build and run capsule
  -> File Manager inspected deployment on one local exact serial
     OR Fleet approved execution over one immutable managed target snapshot
  -> Kiosk catalog/launch/foreground control when the app participates
  -> app-owned effective-runtime evidence
  -> owner-specific cleanup and reconciliation
```

Do not force every operation through all three products. File Manager is the
default local single-headset route. Fleet is the default managed multi-target
route only when its current authority and effect-owner contracts apply. Kiosk
is the default launch front door when the app participates in its catalog or
foreground-control workflow.

Resolve executable paths, targets, aliases, approvals, credentials, and
coordination privately. For routine intents set `raw_fallback_allowed=false`.
Before using raw ADB, record the provider gap, bounded fallback goal, stop
condition, cleanup, and suggested owner-product improvement.

For APK work, choose the build lane before the device loop. Warm iteration may
reuse stable short project/lane-scoped Cargo, Gradle, shell, and product
intermediates; Candidate/publication freezes clean inputs and immutable output
evidence. Both lanes inspect and retain the exact APK. Keep separate
native/shell/package invalidation identities, write generated inputs only when
their bytes change, and label comparable cold/warm phase timings. A cache is
not acceptance evidence, and an observed sub-minute result is not an SLA.

## Core Rules

- Identify the exact headset and use `adb -s <serial> ...` for every device
  command when more than one Android target may exist.
- Treat the default ADB daemon as shared infrastructure. Coordinate exclusive
  work per headset; reserve daemon lifecycle only before disruptive
  kill/start/reconnect, transport, key, binary, or server-port changes.
- Prefer read-only probes before install, launch, grants, file mutation,
  settings changes, forwarding, or capture.
- Preserve power, stay-awake, proximity, settings, app tasks, packages, files,
  and forwards unless the task explicitly changes them.
- Gate state-changing operations with explicit operator intent. Record a
  receipt before dispatch and advance `sent -> pending -> confirmed` only after
  fresh route-specific headset readback matches.
- Treat command exit zero, request admission, and a visible permission prompt
  as dispatch evidence, not confirmation.
- Treat every Quest reboot as an attended recovery boundary. Before issuing
  one, warn that a wearer must be available afterward. ADB reachability and
  Android boot completion do not make the headset ready for app launch,
  OpenXR, capture, or performance work.
- Keep generated APKs, screenshots, captures, traces, logs, serials, package
  identities, signing material, and raw device evidence out of public commits.
- Do not treat ADB synthetic input as Meta Touch/OpenXR controller parity.
- Do not treat screenshots, casting, screenrecord, or MediaProjection as raw
  camera access.
- Keep fused HMD/controller tracking inside the active app's OpenXR session.
- Distinguish app-owned OpenXR, a co-resident native bridge that reuses an
  engine-owned instance/session, and an OpenXR API layer that intercepts the
  loader call chain. Do not start a competing frame loop.
- On Android, treat an app-packaged API layer as part of that target APK's
  explicit feature and permission closure. Do not claim that Termux or an
  ordinary app can attach it to an existing session or inject it into an
  arbitrary installed app.
- Keep high-rate camera, depth, mesh, pose, and video bytes out of JSON
  settings, Android properties, and generic command/status channels.
- Treat an Accessibility foreground watchdog as a user-enabled diagnostic
  capability, not HOME interception or kiosk authority. Disable UI-content
  retrieval, group one Meta Home event burst into one invocation, allow late
  shell tails to request refocus without double-counting escape gestures, and
  revalidate exact signals and background launch behavior after Horizon
  updates.
- Prefer an owning application's typed CLI or local API for a repeatable
  operation it fully supports. Default routine Morphospace work to File
  Manager, Kiosk, and Fleet according to the loop above. Preserve raw
  serial-scoped ADB as a labeled bootstrap, provider-gap, diagnostic, or
  recovery fallback and do not relabel its results as owner acceptance.
- When a machine-local wrapper composes multiple File Manager steps, require
  one exact provider hash and read-locked content-addressed provider/APK copies
  for the complete run. Retain typed failures and stop before launch unless
  installed-byte readback is confirmed; never switch to an ambient repository
  build output between steps.
- When an owner projects
  `rusty.quest.workflow.provider_capability_discovery.v1`, require an exact
  schema, provider version, capability, action, and contract-version match.
  Reject duplicate IDs, future observations, expired descriptors, freshness
  windows over 600 seconds, unknown authentication requirements, and sensitive
  or executable fields. Apply the workflow's semantic validator in addition
  to structural JSON Schema validation: timestamp interval and declared
  maximum age must correspond at exact `TimeSpan` tick precision, observations
  later than the validation clock fail, and provider/capability/contract/
  effect-owner/receipt/action identifiers must reject `command` as a token,
  plus generic shell, ADB, exec/execute, MCP, arbitrary-command, and raw-args
  forms. Preserve only narrowly typed ADB contexts such as
  `request-wireless-adb`, `wifi-adb`, and `wireless-adb`. Require RFC3339
  date-time syntax, with an explicit zone, before timestamp semantics are
  evaluated. Normalize schema-valid numeric offsets through `+23:59` and
  `-23:59` without imposing .NET's narrower 14-hour offset-constructor limit.
  Normalize RFC3339 leap second `:60` to the following second before applying
  the offset. Treat `descriptor-available` as description availability only,
  never backend health, target availability, activation, approval, authority,
  or an execution grant.
- Keep local File Manager and managed Fleet execution contracts disjoint.
  Portable workflow intents contain no private resolver, target, approval, or
  authority fields.
- Preserve owner evidence byte-for-byte and bind only its schema and SHA-256
  from a sanitized workflow wrapper.
- Add MCP only after the owning typed command registry and CLI/local API
  projections are stable. Never expose raw shell, generic ADB arguments,
  arbitrary components/intents/paths/properties/processes, or caller-supplied
  authority.

## Provider Order

Use the narrowest provider that answers the question:

Before choosing, prefer a fresh inert descriptor projected from the owner's
existing typed registry. Do not ask discovery to resolve a target, initialize
a backend, probe a device, obtain credentials, or execute an action. Absence or
rejection of a descriptor is a provider-selection limitation, not permission
to broaden another provider's authority.

1. QuestIonAble File Manager typed CLI/local API for advertised exact-serial
   artifact inspection, inspected install, resolved launch, bounded
   observation, and reviewed local device utilities.
2. Rusty Kiosk, directly or through its bounded File Manager/Fleet adapter, for
   catalog, selection, normal or guarded launch, and Kiosk-owned foreground
   state.
3. App-owned status for OpenXR, renderer, source, effective runtime, clocks,
   streams, and application receipts.
4. Rusty Fleet for approved managed operations over immutable target snapshots
   with current Manifold authority and effect-owner receipts.
5. Rusty Hostess for its typed Windows capture/presentation routes. Its
   Meta/MQDH Cinematic adapter is an opaque supervised presentation provider,
   not a generic Quest/Manifold stream source.
6. Meta Horizon MCP / Meta VR CLI / `hzdb` for Quest-specific docs, device
   status, screenshots, logcat, Perfetto, and assets when configured.
7. ADB fallback for bootstrap, novel diagnostics, provider-gap investigation,
   and
   recovery.
8. App-private diagnostics, normally via `run-as` for debuggable builds.
9. Manual headset action for runtime permissions, MediaProjection consent,
   protected prompts, paid Store steps, and real controller input.

Label the selected provider and version. Choose per operation, not once per
run. Do not substitute one capture or authority source for another without
saying so.

For unattended Meta tooling diagnostics, require the reviewed profile's npm
package/version, distribution integrity, normalized help digest, exact config
digest, bounded artifact paths, metric summary, and cleanup receipt. Do not
project the broader Meta VR CLI or MCP surface through that profile.

## Default Local Product Shape

Use File Manager's current inspected-deployment commands and Kiosk routes from
`docs/rusty-morphospace-default-device-loop.md`. Require exact artifact,
serial, installed-byte, resolved-launcher, foreground, and owner-state
readback. Confirm runtime truth through the participating app.
An installed-byte observe may pass while a Guardian, lock-screen, or Home
Activity keeps foreground/resumed/process state false; keep that launch
blocker as a separate claim.

## Quest Reboot Is Attended

Assume that a rebooted Quest requires physical interaction before immersive
automation can resume. Keep the reboot receipt `pending` after ADB reconnects
and `sys.boot_completed=1`. Ask the wearer to press the physical power button
and clear `SensorLockActivity`, the VR lock screen, or Guardian as needed. Do
not treat ADB wake or key-event injection as a substitute; it may turn the
display on briefly while sensor lock returns the headset to sleep.

Resume only after fresh readback proves all selected prerequisites:

- wakefulness is `Awake` and the physical display is on;
- no sensor-lock, VR-lockscreen, or Guardian surface blocks placement;
- Meta Shell has a valid, advancing vsync; and
- after placement, the target process owns the OpenXR focused/frame-loop
  evidence and any requested refresh-rate or CPU/GPU confirmation used by the
  run.

`mStayOn=true`, ADB connectivity, Android boot completion, or a Shell-owned
VrApi line is insufficient. If the headset returns to sleep, reports invalid
vsync, or logs a volumetric-window placement timeout, stop launch retries and
request the physical action. Exclude the attempt from performance acceptance.

## Raw ADB Fallback Shape

Only after the fallback gate is satisfied, start with serial-scoped readback:

```powershell
adb devices -l
adb -s <serial> shell getprop ro.product.model
adb -s <serial> shell getprop ro.build.version.release
adb -s <serial> shell dumpsys window | findstr /i "mCurrentFocus mFocusedApp"
```

Install and launch only after confirming the target and package:

```powershell
adb -s <serial> install -r -d -g <path-to.apk>
adb -s <serial> shell am start -W -n <package>/<activity>
```

Grant only permissions declared by the APK and required by the selected
profile. Some permissions require manifest declaration or headset UI approval
and cannot be made effective with `pm grant`.

For a bounded log/capture window:

```powershell
adb -s <serial> logcat -c
adb -s <serial> shell am start -W -n <package>/<activity>
adb -s <serial> logcat -d -v threadtime > <out-dir>\logcat.txt
adb -s <serial> exec-out screencap -p > <out-dir>\screenshot.png
```

Capture after an app-owned readiness marker or proven warmup. Reject or bracket
runs contaminated by sleep, display-off, OpenXR exit, fatal exceptions, or an
unexpected protected system prompt.

## Capture And Streaming Boundaries

- Native passthrough is compositor output, not an app-sampleable texture.
- Camera2/Passthrough Camera API is app-visible camera data, not final display.
- Environment depth is neither RGB camera nor final display.
- MediaProjection is a user-consented app/display composite; each session needs
  its own token and lifecycle/cleanup evidence.
- ADB screencap is a still witness with provider-specific policy and timing.
- ADB `exec-out screenrecord --output-format=h264 ... -` can provide raw
  Annex-B physical-display H.264 without an APK or device file on validated
  builds. It may be stereo and lacks useful container timestamps; use an owning
  wrapper, host-arrival clocking, bounded/explicit stop, decode/readiness
  evidence, and `pidof screenrecord` cleanup readback.
- Casting and scrcpy are operator presentation transports, not camera access.
  The Hostess Meta/MQDH adapter's sanitized reviewed-run summary records stable
  live Cinematic 16:9 presentation and graceful owned-host exit on its pinned
  matrix. Limit it to supervised local source use on the reviewed Windows
  machine; it receives no frames or generic media packets, and success does not
  prove recording, input forwarding, arbitrary 2D-panel interaction, Meta
  device-session cleanup, FOV restoration, or general distribution readiness.
- Direct frame/status endpoints prove their route produced content, not that
  the Quest compositor presented the same pixels.

Manifold owns accepted session/stream references. Rusty Quest owns platform
capture lifecycle; Rusty Hostess owns Windows CLI/API/WPF receiver, preview,
evidence, and cleanup routes. Dedicated media bytes do not travel through
Manifold command/status payloads.

## Store, Sidecar, And Local-Service Boundaries

- For organization-managed Store apps, identify Individual versus Shared Mode
  and the active Android user/profile. Never automate purchases, payment, Store
  PIN entry, terms acceptance, or account-holder choices.
- A fresh Android task is not necessarily a fresh process. Do not force-stop
  unrelated Store apps to clean ordinary background tasks.
- Treat Termux as a normal Android app. It becomes ADB-shell-capable only when
  an already-authorized live route reports `uid=2000(shell)`.
- Treat Wi-Fi Direct or LocalOnlyHotspot topology as separate from Wireless ADB
  readiness. Require current TLS listener state and shell-UID readback.
- A Quest-local HTTP/WebSocket service is an app or Manifold adapter. It may
  expose bounded status and acknowledgements; it does not own another app's
  OpenXR frame loop or create parallel command/session/stream authority.
- Termux may be a client of an authenticated typed adapter for an API layer
  already packaged in the foreground XR app. It does not load, attach, or own
  that layer, and raw OpenXR handles or generic injection commands must not be
  exposed through the sidecar.

## Cleanup And Evidence

For each device-facing run, record:

- provider and version;
- serial/model and exact target package/activity or endpoint;
- command goal and operator authorization;
- foreground and effective state before/after;
- prompts or manual actions;
- readiness, status, logcat, capture, and artifact types;
- result, uncertainty, and cleanup readback.

Restore only state owned by the run. Stop only the target package/process,
remove only run-owned forwards/files, restore exact prior values where
recorded, and report anything that could not be restored.

## Stop And Ask

Require explicit operator approval before disruptive ADB daemon work, Wi-Fi ADB
setup/recovery, app uninstall or data clearing, device file deletion, power or
proximity policy changes, paid Store actions, long shared-device builds or
captures, or publishing device-derived/private artifacts.

When durable device, capture, evidence, or repo-routing rules change,
synchronize this skill, the repo `AGENTS.md`, README, and nearest focused
playbook. Keep long recipes in those playbooks rather than expanding this file.
