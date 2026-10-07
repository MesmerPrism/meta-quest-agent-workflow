---
name: meta-quest-workflow
description: 'Use for Meta Quest device operations, APK deployment, capture, diagnostics, and evidence through owned providers.'
---

# Meta Quest Workflow

This public, portable skill routes Quest device operations to focused owner
playbooks. It does not own application composition, runtime features,
command/session/stream authority, targets, credentials, or resource locks.

## Resolve the source, then the operation

In the canonical source checkout, use the adjacent repository's README and
`docs/playbook-index.md`. For an installed skill, run its
`scripts/Resolve-PlaybookSource.ps1 -Json`. The resolver validates
`.morphospace-skill-source.json` and the optional
`references/local-meta-quest-playbooks.json`: use local docs only when it
returns `mode=local`, confirming repository, installed commit, tree, clean
status and paths. Otherwise use the returned `pinned-public` URLs, bound to
the installed source commit, never floating `main`.

An optional `references/local-work-environment.json` resolves the exact local
WEF source for `docs/QUEST_APK_WORKFLOW.md`, `docs/PROJECT_ISOLATION.md`,
`docs/PUBLIC_PRIVATE_BOUNDARY.md`, and `docs/INSTRUCTION_SYNCHRONIZATION.md`.
It is installation metadata outside this canonical skill and cannot override this repository's
device procedure or authorize an effect. If absent, use the repository identified
by the user or ask for its location; never guess a machine path.
See `docs/local-playbook-resolution.md` for resolution failures.

Read only the playbook needed for the current operation. The source index
routes specialized cases; `docs/skill-operation-contracts.md` retains detailed
conditional contracts and examples formerly included here. Neither is a
requirement to load every procedure before ordinary work.

| Operation | Source playbook |
| --- | --- |
| Build, deploy, launch, validate | `docs/rusty-morphospace-default-device-loop.md`; APK iteration uses `docs/quest-apk-build-lanes.md` |
| Select a typed provider or labeled ADB fallback | `docs/agent-execution-providers.md`; `docs/adb-basics.md` |
| Confirm mutation, foreground and effective readiness | `docs/host-headset-mutation-confirmation.md`; `docs/quest-signal-patterns.md` |
| Capture, streaming or OpenXR integration | `docs/capture-source-taxonomy.md`; `docs/quest-streaming-and-direct-link-gates.md`; `docs/openxr-tracking-boundary.md` |
| Evidence, retained state and cleanup | `docs/artifact-and-evidence-discipline.md` |
| Boot Wireless ADB, protected trust and helper updates | `docs/boot-wireless-adb-qualification.md` |
| Meta diagnostic tooling | `docs/meta-vr-cli-evidence-profiles.md` |
| Store, Accessibility, sidecars or BLE/WebSocket control | Select the corresponding focused playbook in `docs/playbook-index.md` |

## Default execution and boundaries

For routine Morphospace work, choose the project-owned build/run capsule,
then File Manager inspected deployment for one exact local serial OR Fleet approved execution
over an immutable managed target snapshot. Use Kiosk for participating
catalog/launch/foreground workflows, then app-owned effective runtime evidence
and owner-specific cleanup. Choose per operation; every run does not need all
providers. Bind exact provider/artifact/target identity.

Continue within user/session authorization. Ask only for missing material
intent or an expansion of scope; prior authorization remains valid. Protected
wearer approval and account-holder decisions remain real platform boundaries.
Prefer typed owner CLI/local APIs for supported operations. Routine intents
use `raw_fallback_allowed=false`; before raw serial-scoped ADB, record the
provider gap, bounded goal, stop condition, cleanup and owner improvement.
Preserve exact provider/APK copies across a composed deployment, typed failures
and installed-byte readback before launch. A cache is not acceptance evidence.

Coordinate exclusive headset work and disruptive ADB daemon/transport changes.
Normal serial-scoped discovery/readback uses the shared daemon. Preserve
unrelated device/app state. Record mutation intent before dispatch; advance
`sent -> pending -> confirmed` only after fresh route-specific effective
readback. Exit zero, admission and permission prompts prove dispatch alone.

Keep local File Manager and managed Fleet contracts disjoint. Discovery is
inert description, never backend health, target selection, approval or an
execution grant. Validate the selected descriptor with its structural and
semantic owner checks; see the conditional contracts for exact freshness,
timestamp and identifier rules. Never expose generic shell/ADB/raw arguments
or caller-supplied authority through discovery or MCP. Manifold owns accepted
command/session/stream authority; Quest owns platform adapters. WEF owns
composition/isolation. Consult `docs/rusty-morphospace-repo-routing.md` for
other owners. Rusty XR remains historical compatibility provenance only.

## Quest Reboot Is Attended

Warn before an authorized reboot that a wearer must be available afterward.
Keep its receipt pending after ADB reconnect and Android boot completion.
The wearer may need the physical power button and must clear SensorLockActivity,
VR lock screen or Guardian. ADB wake/key injection is insufficient.
Resume selected immersive work only after fresh readback proves awake/display
on, no blocking surface, advancing valid Shell vsync and, after placement, the
target process owns the OpenXR focused/frame-loop evidence and any selected
performance confirmation. Stop launch retries if sleep, invalid vsync or
placement timeout returns; exclude that attempt from performance acceptance.

## Evidence and completion

Confirm installed bytes for install, resolved launcher/foreground for launch,
and app-owned state for runtime. Keep those claims separate. Preserve owner
evidence byte-for-byte; sanitized wrappers bind its schema and SHA-256.
Keep serials, signing material, generated APKs, raw logs/captures and private
evidence outside public commits. High-rate media uses dedicated data routes.
Capture providers prove their own source: screenshots/casting do not prove
camera access, presentation or another app's OpenXR state. An API layer belongs
to its target APK closure; a sidecar cannot inject it into arbitrary apps or
start a competing frame loop. ADB input is not Touch controller parity.

Retain authorized app/runtime changes by default and report deltas. Restore
only when requested, explicitly temporary or required by the actual owner
contract. Stop run-owned workers, recorders, forwards, ports and leases according
to that contract; do not undo the requested final state. Report provider/version,
exact target, goal/authorization, effective before/after state, artifacts,
result/uncertainty and cleanup readback needed for the claim.

When durable rules change, synchronize this canonical skill, repository
AGENTS/README and affected playbook; keep conditional recipes in owner docs.