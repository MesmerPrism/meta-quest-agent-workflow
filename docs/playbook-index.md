# Playbook And Owner Index

Use this index to select the smallest relevant Meta Quest playbook and then
follow the linked application contract for executable behavior. Meta workflow
docs own portable procedure and evidence boundaries. They do not replace
application command, authorization, effective-state, receipt, or cleanup
authority.

Empirical Quest, Horizon OS, UI, and tool observations remain versioned
evidence. Recheck the current device/tool build before treating them as current.

| Task | Meta workflow playbook | Application or protocol owner |
| --- | --- | --- |
| Resolve repository playbooks from an installed router skill | [Local playbook resolution](local-playbook-resolution.md) | Installed provenance and the exact canonical Meta Quest workflow commit own the documentation identity; the locator grants no runtime authority |
| Routine build, deploy, launch, validate, and cleanup | [Default device loop](rusty-morphospace-default-device-loop.md) | [QFM inspected deployment](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/inspected-deployment.md), [Kiosk CLI](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/CLI.md), [Fleet workflow](https://github.com/MesmerPrism/rusty-fleet/blob/main/docs/WORKFLOW.md) |
| Repository, composition, and public/private routing | [Repository routing](rusty-morphospace-repo-routing.md) | [Work Environment repository lanes](https://github.com/MesmerPrism/rusty-morphospace-work-environment/blob/main/docs/REPO_LANES.md) |
| Choose File Manager, Kiosk, Fleet, Meta tooling, ADB, or app evidence | [Agent execution providers](agent-execution-providers.md) | [QFM CLI parity](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/operator-cli-parity.md), [Kiosk direct operator](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/DIRECT_OPERATOR.md), [Fleet provider catalog](https://github.com/MesmerPrism/rusty-fleet/blob/main/docs/PROVIDER_CAPABILITY_CATALOG.md) |
| ADB bootstrap, discovery, focus, files, logs, forwarding, or fallback | [ADB basics](adb-basics.md) | Android/Meta tooling supplies the transport; the selected app still owns effective state |
| Raw APK fallback or routine inspected deployment | [APK install and launch](apk-install-launch.md) | [QFM inspected deployment](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/inspected-deployment.md) |
| Run manifests, artifact provenance, evidence promotion, and public sharing | [Artifact and evidence discipline](artifact-and-evidence-discipline.md) | Preserve byte-exact receipts from the selected effect owner |
| Readiness, foreground, capture timing, logs, and rejection signals | [Quest signal patterns](quest-signal-patterns.md) | The participating app owns current effective runtime |
| Accessibility, Meta Home transitions, foreground guard, and return behavior | [Accessibility and foreground watchdogs](accessibility-foreground-watchdogs.md) | [Kiosk foreground signal](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/FOREGROUND_SIGNAL.md) and [user control](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/USER_CONTROL.md) |
| Screenshots, recording, screenrecord, MediaProjection, UI capture, or Cinematic casting | [Capture stack notes](quest-capture-stack-notes.md) and [capture taxonomy](capture-source-taxonomy.md) | The selected Meta/platform tool, Android/ADB transport, MediaProjection application, Rusty Quest adapter, or Hostess route owns only its declared effect; see [Rusty Quest media runtime](https://github.com/MesmerPrism/rusty-quest/blob/main/docs/MEDIA_STREAM_RUNTIME.md) and [Rusty Hostess](https://github.com/MesmerPrism/rusty-hostess) (`docs/EVIDENCE_BUNDLE.md` and `docs/meta-quest-casting-adapter.md`) when those providers are selected |
| Quest/Quest or Quest/PC streaming and direct-link promotion | [Streaming and direct-link gates](quest-streaming-and-direct-link-gates.md) | [Manifold media authority](https://github.com/MesmerPrism/rusty-manifold/blob/main/docs/MEDIA_SESSION_AUTHORITY.md), [Rusty Quest remote streaming](https://github.com/MesmerPrism/rusty-quest/blob/main/docs/REMOTE_CAMERA_STREAMING.md), selected peer/host provider |
| Termux, X11, Proot, VNC, off-LAN control, or Wireless ADB | [Termux and Linux sidecars](termux-linux-sidecars.md) | The selected sidecar application owns its endpoint; no shell, HOME, app socket, or Manifold authority is implied |
| Managed Individual/Shared Mode or Store-installed applications | [Managed device and Store apps](managed-device-store-apps.md) | Meta managed-device/Store policy, the organization administrator, account entitlement, distribution route, and selected application retain their separate authority; [Fleet](https://github.com/MesmerPrism/rusty-fleet/blob/main/docs/WORKFLOW.md) owns only an explicitly selected orchestration operation |
| Meta VR CLI, Horizon MCP, `metavr`, or `hzdb` | [Meta Horizon MCP and hzdb](meta-horizon-mcp-and-hzdb.md) | Meta tooling is an optional evidence provider, not application authority |
| Any host or headset state mutation | [Host/headset mutation confirmation](host-headset-mutation-confirmation.md) | Use the selected owner's registered command, authorization, receipt, and restoration contract |
| Permissions, package distribution, or protected platform capabilities | [Permissions and distribution](permissions-and-distribution-boundary.md) | The application manifest and distribution owner remain authoritative |
| OpenXR session, tracking, relation semantics, or presentation state | [OpenXR tracking boundary](openxr-tracking-boundary.md) | [Rusty Quest architecture](https://github.com/MesmerPrism/rusty-quest/blob/main/docs/ARCHITECTURE.md) and the participating app; Manifold owns only selected accepted routes |
| Camera2/Passthrough Camera metadata and route evidence | [Camera metadata collection](camera-metadata-collection.md) | Rusty Quest/app owns capture state; projection semantics belong to the projection owner |
| Cross-app `content://`, URI grants, handoff, and completion | [Cross-app content URI IPC](cross-app-content-uri-ipc.md) | The concrete caller and callee own their exported components and receipts |
| App-owned localhost status or diagnostic endpoints | [Broker-style localhost probes](broker-style-localhost-probes.md) | The application owns endpoint schema/effective status; [Manifold](https://github.com/MesmerPrism/rusty-manifold/blob/main/docs/COMMANDS_LEASES_AND_AUTHORITY.md) owns selected accepted command/session authority |
| ADB-launched shell helpers | [Shell helper boundary](shell-helper-boundary.md) | External authorized ADB host owns launch; helper and installed app identities remain separate |
| Long-run awake/proximity stability and watchdog cleanup | [Long-running watchdogs](long-running-watchdogs.md) | [QFM awake control](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/quest-awake-control.md) or [Fleet awake control](https://github.com/MesmerPrism/rusty-fleet/blob/main/docs/QUEST_AWAKE_CONTROL.md) when selected |
| Questionnaire-panel handoff | [XR questionnaire handoff](xr-questionnaire-panel-handoff.md) | The concrete caller/callee app contracts remain authoritative |
| Failure triage | [Troubleshooting](troubleshooting.md) | Follow the symptom to the focused playbook and selected owner; do not substitute a generic command |

## Distribution Rule

Global skills route across owners. Application `AGENTS.md`, help, schemas, and
generated agent bundles describe only that application's capabilities and
receipts. Project-local instructions own live project state. Private planning
and evidence own machine paths, identities, credentials, raw captures, and
unsanitized decisions.
