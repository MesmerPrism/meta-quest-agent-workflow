# Meta Quest Agent Workflow

Portable agent workflow notes for Meta Quest development, ADB validation,
Quest APK install/launch loops, Camera2 metadata collection, capture-source
taxonomy, and Meta Horizon MCP / `hzdb` usage.

This repository packages a public-safe version of the local workflow patterns
used while building Rusty XR. It is intentionally generic: commands use
placeholders, generated artifacts stay out of source control, and side effects
are split from read-only inspection.

## What Is Included

- A Codex-style skill at `skills/meta-quest-workflow/SKILL.md`.
- ADB install, grant, launch, logcat, screenshot, and artifact collection
  workflows.
- Quest camera metadata collection through ADB and optional broker-style
  localhost probes.
- Long-running watchdog guidance for ADB-launched device-side helpers that keep
  a development headset awake without pretending to be an APK permission.
- Termux, Termux:X11, Proot, local dashboard, and localhost-only VNC guidance
  for lab sidecars that stay separate from HOME, ADB shell authority, and XR
  runtime ownership.
- Cross-package XR questionnaire panel handoff guidance for validating a
  foreground XR app launching a reusable 2D panel app and returning to the same
  XR app, with a caller-owned `content://` result URI for answers and no ADB,
  force-stop, package killing, public shared storage, or Meta menu navigation in
  the product path.
- A generic cross-app content-URI IPC hardening checklist covering
  `FileProvider` scope, package visibility, PendingIntent identity and
  background-launch behavior, Quest permission constraints, lifecycle recovery,
  backup policy, and result-channel validation.
- Quest readiness and signal-pattern notes for deciding when screenshots,
  logcat windows, and evidence captures are meaningful.
- Capture-source taxonomy for passthrough, raw camera, environment depth,
  MediaProjection, screenshots, casting, and direct stream-frame witnesses.
- Meta Horizon MCP / `hzdb` setup notes and safety boundaries.
- OpenXR tracking and ADB shell-helper boundaries.
- Reusable PowerShell scripts under `examples/`.

## What Is Not Included

- Local machine paths, private repo names, private package identities, signing
  material, device serials, generated screenshots, APKs, or log bundles.
- A bundled copy of `hzdb`, ADB, Meta SDKs, OpenXR loaders, codec libraries, or
  any generated tool cache.
- A promise that shell helpers, ADB, or MCP can bypass headset permissions or
  platform policy.

## Quick Start

Use the skill from an agent that supports local skills:

```text
Use the meta-quest-workflow skill before touching a Quest headset, ADB,
APK install/launch, logcat, screenshots, Perfetto, or Meta Horizon MCP tools.
```

For a direct terminal workflow:

```powershell
adb devices -l
adb -s <serial> shell getprop ro.product.model
adb -s <serial> install -r -d -g <path-to.apk>
adb -s <serial> shell am start -n <package>/<activity>
adb -s <serial> logcat -d -v threadtime > artifacts/logcat.txt
```

For camera metadata collection:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\examples\collect-camera-metadata.ps1 `
  -Serial <serial> `
  -OutDir .\artifacts\quest-camera-metadata
```

For a launch-and-watch loop:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\examples\install-launch-watch.ps1 `
  -Serial <serial> `
  -Apk <path-to.apk> `
  -Package <package> `
  -Activity <activity> `
  -OutDir .\artifacts\launch-smoke
```

## Core Rules

1. Use placeholders in public notes: `<serial>`, `<package>`, `<activity>`,
   `<apk>`, `<out-dir>`.
2. Keep generated artifacts out of git.
3. Prefer read-only probes first.
4. Preserve headset power, stay-awake, and proximity state unless the current
   test explicitly needs to change them.
5. Treat ADB grants and launch commands as developer workflows, not production
   user experience.
6. Do not treat ADB synthetic input as proof of Meta Touch/OpenXR controller
   input.
7. Do not treat MediaProjection, screenshots, casting, or screenrecord as raw
   camera access.
8. Keep fused HMD/controller tracking inside the active XR app's OpenXR
   session.
9. Gate app lifecycle, file mutation, device settings, shell commands, network
   forwarding, and Perfetto capture with an explicit operator decision.
10. Record provider, command goal, fallback, foreground before/after, and
    artifact paths for every device-facing run.

## Provider Model

Use the narrowest provider that answers the question:

| Provider | Good for | Notes |
| --- | --- | --- |
| App/broker status endpoint | App-owned health, clock, stream state | Requires the app or service to be running. |
| Meta Horizon MCP / `hzdb` | Quest-specific docs, device status, logcat, screenshots, Perfetto, assets | Optional provider; verify availability first. |
| ADB | Install, launch, logcat, screenshot, dumpsys, file push/pull, port forward | Developer Mode and user ADB authorization required. |
| App-private diagnostics | Camera/source metadata, renderer counters, probe payloads | Pull with `run-as` only when the app is debuggable. |
| Manual headset action | Permissions, MediaProjection consent, protected prompts, real controllers | Record the user action in the evidence. |

## Repository Layout

```text
skills/meta-quest-workflow/SKILL.md
docs/adb-basics.md
docs/apk-install-launch.md
docs/artifact-and-evidence-discipline.md
docs/broker-style-localhost-probes.md
docs/camera-metadata-collection.md
docs/capture-source-taxonomy.md
docs/cross-app-content-uri-ipc.md
docs/long-running-watchdogs.md
docs/termux-linux-sidecars.md
docs/xr-questionnaire-panel-handoff.md
docs/meta-horizon-mcp-and-hzdb.md
docs/permissions-and-distribution-boundary.md
docs/openxr-tracking-boundary.md
docs/quest-signal-patterns.md
docs/shell-helper-boundary.md
docs/troubleshooting.md
examples/collect-camera-metadata.ps1
examples/install-launch-watch.ps1
examples/broker-status-probe.ps1
examples/start-device-watchdog-template.ps1
examples/mcp-config-example.json
scripts/check-public-safe.ps1
```

## Source Lineage

This repository is derived from public Rusty XR documentation and local
workflow experience, sanitized into a project-independent form. The upstream
source project is:

- Rusty XR: https://github.com/MesmerPrism/Rusty-XR

See `NOTICE.md` for details.

## License

MIT. See `LICENSE`.
