---
name: meta-quest-workflow
description: 'Use for Meta Quest device work: serial-scoped ADB, APK install/launch/validation, screenshots, screenrecord, logcat, Perfetto, Camera2 metadata, MediaProjection, Termux sidecars, Manifold/app-owned localhost probes, or Meta Horizon MCP / Meta VR CLI / hzdb workflows.'
---

# Meta Quest Workflow

Use this skill before touching a Meta Quest headset, ADB transport, APK
install/launch, screenshots, screenrecord, logcat, Perfetto, camera metadata,
MediaProjection, Wi-Fi ADB, or Quest-specific MCP tooling.

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
  validation, cleanup, and evidence projection;
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

## First Read

Read only the playbooks needed for the task:

1. `README.md`
2. `docs/adb-basics.md`
3. `docs/agent-execution-providers.md`
4. `docs/apk-install-launch.md`
5. `docs/artifact-and-evidence-discipline.md`
6. `docs/quest-signal-patterns.md`
7. `docs/accessibility-foreground-watchdogs.md` for attended foreground
   monitoring, Meta Home transitions, or special Accessibility enablement
8. `docs/host-headset-mutation-confirmation.md` for state changes
9. `docs/managed-device-store-apps.md` for managed modes or Store apps
10. `docs/quest-capture-stack-notes.md` and
   `docs/capture-source-taxonomy.md` for capture or streaming
11. `docs/termux-linux-sidecars.md` when Termux or Wi-Fi ADB is involved
12. `docs/meta-horizon-mcp-and-hzdb.md` for Meta VR CLI/MCP

When this skill is installed without the repo docs, use the public
`MesmerPrism/meta-quest-agent-workflow` repository as the playbook source.

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
- Keep generated APKs, screenshots, captures, traces, logs, serials, package
  identities, signing material, and raw device evidence out of public commits.
- Do not treat ADB synthetic input as Meta Touch/OpenXR controller parity.
- Do not treat screenshots, casting, screenrecord, or MediaProjection as raw
  camera access.
- Keep fused HMD/controller tracking inside the active app's OpenXR session.
- Keep high-rate camera, depth, mesh, pose, and video bytes out of JSON
  settings, Android properties, and generic command/status channels.
- Treat an Accessibility foreground watchdog as a user-enabled diagnostic
  capability, not HOME interception or kiosk authority. Disable UI-content
  retrieval, group one Meta Home event burst into one invocation, allow late
  shell tails to request refocus without double-counting escape gestures, and
  revalidate exact signals and background launch behavior after Horizon
  updates.
- Prefer an owning application's typed CLI or local API for a repeatable
  operation it fully supports. Preserve raw serial-scoped ADB as a labeled
  diagnostic fallback and do not relabel its results as owner acceptance.
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

1. App-owned status for OpenXR, renderer, source, effective runtime, clocks,
   streams, and application receipts.
2. QuestIonAble File Manager typed CLI/local API for advertised exact-serial
   artifact inspection, inspected install, resolved launch, bounded
   observation, and reviewed local device utilities.
3. Rusty Fleet for approved managed operations over immutable target snapshots
   with current Manifold authority and effect-owner receipts.
4. Meta Horizon MCP / Meta VR CLI / `hzdb` for Quest-specific docs, device
   status, screenshots, logcat, Perfetto, and assets when configured.
5. ADB fallback for novel diagnostics, provider-gap investigation, and
   recovery.
6. App-private diagnostics, normally via `run-as` for debuggable builds.
7. Manual headset action for runtime permissions, MediaProjection consent,
   protected prompts, paid Store steps, and real controller input.

Label the selected provider and version. Choose per operation, not once per
run. Do not substitute one capture or authority source for another without
saying so.

## Safe Device Shape

Start with serial-scoped readback:

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
