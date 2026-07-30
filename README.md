# Meta Quest Agent Workflow

Portable agent workflow notes for Meta Quest development, ADB validation,
Quest APK install/launch loops, Camera2 metadata collection, capture-source
taxonomy, and Meta Horizon MCP / `hzdb` usage.
Current public Meta docs name this tool family Meta VR CLI and use `metavr`
for new manual `npx` setup; `hzdb` remains a compatibility name for older
MQDH/editor bundles and historical traces.

This repository packages the public-safe Meta Quest device-operation workflow
used by the Rusty Morphospace repo family. It is intentionally generic:
commands use placeholders, generated artifacts stay out of source control, and
side effects are split from read-only inspection.

## What Is Included

- A Codex-style skill at `skills/meta-quest-workflow/SKILL.md`.
- A current [Rusty Morphospace repo-routing map](docs/rusty-morphospace-repo-routing.md)
  that keeps device workflow, Quest runtime, Hostess orchestration, Manifold
  authority, and reusable core contracts separate.
- A [default Rusty Morphospace device loop](docs/rusty-morphospace-default-device-loop.md)
  that routes local work through File Manager and Kiosk, managed work through
  Fleet and effect owners, and raw ADB only through an explicit fallback gate.
- ADB install, grant, launch, logcat, screenshot, and artifact collection
  workflows.
- Quest camera metadata collection through ADB and optional broker-style
  localhost probes.
- Long-running watchdog guidance for ADB-launched device-side helpers that keep
  a development headset awake without pretending to be an APK permission.
- Privacy-minimized Accessibility foreground-watchdog guidance for observing
  top-level window transitions, grouping Meta Home event bursts, restoring an
  exported target activity, and preserving a deliberate escape route without
  claiming HOME interception or kiosk authority.
- Termux, Termux:X11, Proot, local dashboard, and localhost-only VNC guidance
  for lab sidecars that stay separate from HOME, ADB shell authority, and XR
  runtime ownership, including the bounded loopback WiFi ADB case after normal
  user authorization, the tested infrastructure-network requirement for
  modern TLS Wireless Debugging, and the visible helper restart case for a
  stopped Termux fleet agent.
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
  MediaProjection, screenshots, ADB `screenrecord`, casting, and direct
  stream-frame witnesses.
- Meta Horizon MCP / Meta VR CLI setup notes and `hzdb` compatibility
  boundaries.
- Managed Individual/Shared Mode Store checks, attended paid-entitlement
  validation, and launcher task/process boundaries.
- Host-to-headset mutation receipts that distinguish command dispatch from
  pending wearer/device work and confirmation by effective-state readback.
- Target-free, short-lived provider capability discovery that describes typed
  owner surfaces without granting execution or exposing invocation details,
  paths, endpoints, targets, credentials, raw arguments, shell access, or MCP
  execution, with a reusable structural-plus-semantic descriptor validator.
- OpenXR tracking and ADB shell-helper boundaries.
- Reusable PowerShell scripts under `examples/`.

## What Is Not Included

- Local machine paths, private repo names, private package identities, signing
  material, device serials, generated screenshots, APKs, or log bundles.
- A bundled copy of Meta VR CLI, `hzdb`, ADB, Meta SDKs, OpenXR loaders, codec
  libraries, or any generated tool cache.
- A promise that shell helpers, ADB, or MCP can bypass headset permissions or
  platform policy.

## Quick Start

Use PowerShell `7.6` LTS or newer through `pwsh` for repository scripts and
PowerShell examples.

Use the skill from an agent that supports local skills:

```text
Use the meta-quest-workflow skill before touching a Quest headset, ADB,
APK install/launch, logcat, screenshots, Perfetto, or Meta Horizon MCP tools.
```

For routine Rusty Morphospace work, start with the product loop:

```powershell
$FileManager = "<file-manager-cli>"
& $FileManager apk inspect --file <path-to.apk> --json
& $FileManager apk install --serial <serial> --file <path-to.apk> --json
& $FileManager kiosk status --serial <serial> --json
& $FileManager apk observe --serial <serial> --file <path-to.apk> --json
```

Use Kiosk's typed launch route when the app participates in its catalog. Use
File Manager's resolved `apk launch` route otherwise. For managed targets, use
Fleet's approved target-snapshot operation instead of translating local
arguments. See
[Rusty Morphospace Default Device Loop](docs/rusty-morphospace-default-device-loop.md).

The ADB examples in the focused playbooks are bootstrap, provider-gap,
diagnostic, or recovery fallbacks. Record the gap before using them.

For camera metadata collection:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File .\examples\collect-camera-metadata.ps1 `
  -Serial <serial> `
  -OutDir .\artifacts\quest-camera-metadata
```

For a launch-and-watch loop:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
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
4. Keep the default ADB daemon shared for serial-scoped clients. Coordinate
   exclusive work per headset, and lock the daemon lifecycle only for global
   reset, recovery, transport, key, binary, or port changes.
5. Preserve headset power, stay-awake, and proximity state unless the current
   test explicitly needs to change them.
6. Treat ADB grants and launch commands as developer workflows, not production
   user experience.
7. Do not treat ADB synthetic input as proof of Meta Touch/OpenXR controller
   input.
8. Do not treat MediaProjection, screenshots, casting, or screenrecord as raw
   camera access.
9. Keep fused HMD/controller tracking inside the active XR app's OpenXR
   session.
10. Gate app lifecycle, file mutation, device settings, shell commands, network
   forwarding, and Perfetto capture with an explicit operator decision.
11. Record provider, command goal, fallback, foreground before/after, and
    artifact paths for every device-facing run.
12. Keep topology proof separate from Wireless ADB proof. A Quest-owned Wi-Fi
    Direct group or local-only hotspot can provide local networking while the
    tested Horizon OS build still refuses to start its TLS ADB listener.
13. Treat paid Store purchases as attended account-holder actions. Automation
    may inspect or open the Store but must not choose, buy, enter a Store PIN,
    or provide payment.
14. Distinguish a fresh Android task from a fresh process. Do not force-stop
    arbitrary Store apps merely to clean normal background tasks.
15. Model every state-changing PC command as `sent -> pending -> confirmed`.
    Confirm only from fresh route-specific headset readback; a prompt request
    or zero process exit code is not confirmation.
16. Treat Accessibility foreground monitoring as a special user-enabled
    capability: disable UI-tree retrieval, separate refocus from escape
    counting, and revalidate Meta-shell signals after Horizon updates.
17. Default routine local work to File Manager inspected deployment, Kiosk
    launch/foreground control when applicable, and app-owned runtime evidence.
    Default managed target-set work to Fleet with current authority and
    effect-owner receipts.
18. Preserve raw serial-scoped ADB only as an explicitly labeled bootstrap,
    provider-gap, diagnostic, or recovery fallback, not equivalent owner
    evidence.

## Provider Model

Use the narrowest provider that answers the question:

| Provider | Good for | Notes |
| --- | --- | --- |
| QuestIonAble File Manager typed CLI/local API | Exact-serial artifact inspection, inspected install, resolved launch, bounded package/foreground/process observation, and reviewed local device utilities | Preferred local provider only for advertised typed commands with fresh operation-specific readback. It owns no Fleet or Manifold authority. |
| Rusty Kiosk typed provider | Catalog, selected app, normal or guarded launch, foreground guard, and return-to-Kiosk state | Kiosk owns these effects even when File Manager or Fleet transports the request. |
| App/Manifold-adapter status endpoint | App-owned health, clock, stream state | Requires the app or service to be running; the endpoint does not replace Manifold authority. |
| Rusty Fleet | Approved operations over immutable managed target snapshots | Requires current Manifold command/lease authority and effect-owner receipts. Local ADB requests and Fleet requests are deliberately different contracts. |
| Meta Horizon MCP / Meta VR CLI / `hzdb` | Quest-specific docs, device status, logcat, screenshots, Perfetto, assets | Optional provider; prefer `npx -y metavr` for new manual setup and record the selected route. |
| ADB fallback | Novel diagnostics, provider-gap investigation, and recovery | Developer Mode and user authorization required. Label the fallback; transport readback cannot be relabeled as app, File Manager, Fleet, or Manifold acceptance. |
| App-private diagnostics | Camera/source metadata, renderer counters, probe payloads | Pull with `run-as` only when the app is debuggable. |
| Manual headset action | Permissions, MediaProjection consent, protected prompts, real controllers | Record the user action in the evidence. |

See [Agent Execution Providers](docs/agent-execution-providers.md) for the
provider-selection algorithm, deliberately disjoint local/Fleet contracts,
portable non-executable intent, sanitized evidence wrapper, and MCP boundary.

## Rusty Morphospace Routing

This repository owns portable device-operation procedure, not the complete
application stack. Current work routes through these public owners:

| Concern | Public owner |
| --- | --- |
| Portable project workflow, exact composition, isolation, and feature locks | [rusty-morphospace-work-environment](https://github.com/MesmerPrism/rusty-morphospace-work-environment) |
| Quest/Android/OpenXR/Spatial SDK apps and platform receipts | [rusty-quest](https://github.com/MesmerPrism/rusty-quest) |
| Windows CLI/API and WPF install, capture, validation, and evidence workflows | [rusty-hostess](https://github.com/MesmerPrism/rusty-hostess) |
| Multi-headset Hub, Console, `fleetctl`, operator policy, and no-ADB monitoring | [rusty-fleet](https://github.com/MesmerPrism/rusty-fleet) |
| Command, session, stream, admission, and control-transport authority | [rusty-manifold](https://github.com/MesmerPrism/rusty-manifold) |
| Tracked-space relations and poses | [rusty-lattice](https://github.com/MesmerPrism/rusty-lattice) |
| Computational and renderer-neutral visual contracts | [rusty-matter](https://github.com/MesmerPrism/rusty-matter) and [rusty-optics](https://github.com/MesmerPrism/rusty-optics) |

See [Rusty Morphospace Repo Routing](docs/rusty-morphospace-repo-routing.md)
for the complete public repo-family map and the legacy compatibility boundary.

## Versioned Quest/Unity Notes

As of the 2026-06-16 public-source check, Horizon OS 2.x changes validation
context: record exact OS and PTC state, Navigator/Home surface, restored or
snapped panels, privacy indicators, and any Meta system UI that appears during
a run. That check observed the Meta XR SDK 203.0 release line, Unity
6000.0.66f2 minimums for several packages,
`XR_META_temporal_pixel_synthesis`, and Spatial SDK 0.13.1 additions. Treat
those as dated evidence: verify Meta's current release notes and the project's
pinned versions before changing a build.

For off-LAN Termux agents, remote-session leases, UIAutomator scenario
bridges, and MediaProjection preview boundaries, start with
`docs/termux-linux-sidecars.md`. That lane is a typed, outbound
remote-operations console pattern, not a browser shell or raw ADB proxy.

## Repository Layout

```text
AGENTS.md
skills/meta-quest-workflow/SKILL.md
docs/adb-basics.md
docs/accessibility-foreground-watchdogs.md
docs/apk-install-launch.md
docs/artifact-and-evidence-discipline.md
docs/broker-style-localhost-probes.md
docs/rusty-morphospace-default-device-loop.md
docs/rusty-morphospace-repo-routing.md
docs/camera-metadata-collection.md
docs/capture-source-taxonomy.md
docs/quest-capture-stack-notes.md
docs/cross-app-content-uri-ipc.md
docs/long-running-watchdogs.md
docs/termux-linux-sidecars.md
docs/xr-questionnaire-panel-handoff.md
docs/meta-horizon-mcp-and-hzdb.md
docs/managed-device-store-apps.md
docs/host-headset-mutation-confirmation.md
docs/permissions-and-distribution-boundary.md
docs/openxr-tracking-boundary.md
docs/quest-signal-patterns.md
docs/shell-helper-boundary.md
docs/troubleshooting.md
examples/agent-execution-intent.json
examples/agent-execution-evidence-wrapper.json
examples/collect-camera-metadata.ps1
examples/install-launch-watch.ps1
examples/broker-status-probe.ps1
examples/start-device-watchdog-template.ps1
examples/mcp-config-example.json
scripts/check-public-safe.ps1
scripts/check-rusty-morphospace-routing.ps1
scripts/Test-AgentExecutionContracts.ps1
schemas/rusty.quest.workflow.intent.v1.schema.json
schemas/rusty.quest.workflow.evidence_wrapper.v1.schema.json
```

## Historical Lineage

Earlier public documentation contributed to this repository's initial
workflow notes. That provenance remains recorded in `NOTICE.md`; it is not the
active repo-routing model for new Rusty Morphospace work.

## License

MIT. See `LICENSE`.
