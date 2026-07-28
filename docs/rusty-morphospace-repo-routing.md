# Rusty Morphospace Repo Routing

Rusty Morphospace is the ecosystem umbrella. Concrete authority remains in
focused repositories. This repository owns portable Meta Quest device-operation
procedure; it does not own application composition, runtime features, command
authority, tracked-space models, or desktop operator policy.

The public work-environment release `v0.5.0` is the current portable workflow
baseline. It adds exact multi-repository composition locks, detached
materializations, local resource claims, revision checkpoints, repeated
same-headset run capsules, and extraction-bound promotion reviews without
changing the separately governed runtime/module baseline.

## Current Public Repositories

| Repository | Current role |
| --- | --- |
| [rusty-morphospace-work-environment](https://github.com/MesmerPrism/rusty-morphospace-work-environment) | Portable onboarding, project composition, feature locks, workspace isolation, and workflow contracts. |
| [rusty-quest](https://github.com/MesmerPrism/rusty-quest) | Quest/Android/OpenXR/Spatial SDK apps and platform adapters, permissions, packaging, lifecycle, and effective-runtime evidence. |
| [QuestIonAble File Manager](https://github.com/MesmerPrism/QuestIonAble-File-Manager) | Windows-first exact-serial ADB/file/APK utilities through shared typed CLI, local API, and WPF routes. It owns local execution only for advertised commands and no managed Fleet or Manifold authority. |
| [rusty-hostess](https://github.com/MesmerPrism/rusty-hostess) | Windows CLI/API and WPF operator routes for install, launch, capture, validation, cleanup, and evidence projection. |
| [rusty-fleet](https://github.com/MesmerPrism/rusty-fleet) | Multi-headset Fleet Hub, Fleet Console, `fleetctl`, operator policy, enrollment/status projections, and no-ADB monitoring. The permission-minimal Quest Fleet Agent producer remains in Rusty Quest. |
| [rusty-manifold](https://github.com/MesmerPrism/rusty-manifold) | Command, session, stream, host-manifest, admission, and control-transport authority. |
| [rusty-manifold-packages](https://github.com/MesmerPrism/rusty-manifold-packages) | Product-specific Manifold packages that must not broaden core authority. |
| [rusty-lattice](https://github.com/MesmerPrism/rusty-lattice) | Reference spaces, transforms, poses, view sets, validity, confidence, staleness, and capability snapshots. |
| [rusty-matter](https://github.com/MesmerPrism/rusty-matter) | Computational matter, geometry, SDF, particles, sampling, dynamics, and deterministic CPU contracts. |
| [rusty-optics](https://github.com/MesmerPrism/rusty-optics) | Renderer-neutral appearance, projection, camera/image metadata, and prepared visual payloads. |
| [rusty-gui](https://github.com/MesmerPrism/rusty-gui) | Portable interaction descriptors and command bindings with CLI/API parity. |
| [rusty-lsl](https://github.com/MesmerPrism/rusty-lsl) | Independently authored LSL compatibility and typed observations/proposals without Manifold authority. |
| [quest-termux-lab](https://github.com/MesmerPrism/quest-termux-lab) | Public lab for bounded Termux sidecars and advisory Quest experiments. |
| [rusty-quest-sidecar-mesh](https://github.com/MesmerPrism/rusty-quest-sidecar-mesh) | Sanitized Quest sidecar integration contracts; advisory evidence does not become Manifold authority. |

## Device Workflow Boundary

Use this repository for the device-facing procedure around those owners:

```text
project composition and exact feature lock
  -> Rusty Quest build and runtime/profile authority
  -> this repo selects an owning typed provider per operation
  -> QuestIonAble File Manager for supported local exact-serial utilities
     OR raw serial-scoped ADB as an explicitly labeled diagnostic fallback
  -> Rusty Quest Fleet Agent proposal when fleet monitoring is enabled
  -> Rusty Fleet ingress verifies Fleet enrollment and signer binding
  -> the pinned Manifold adapter reviews peer-status authority
  -> both Fleet and Manifold transitions apply, or neither does
  -> Rusty Hostess CLI/API-equivalent orchestration and evidence projection
  -> effective-runtime and cleanup readback
```

For commands, sessions, streams, and peer state, Manifold owns the accepted
contract and revision. A Quest-local HTTP/WebSocket service, ADB forward, Binder
surface, or sidecar is a transport/platform adapter. It must not define a
second command or stream authority.

Rusty Fleet owns the multi-headset product and fleet-level projections, but it
does not discover or silently enroll a headset through this device-workflow
repository. Its permission-minimal baseline consumes explicit app-private
configuration in the Rusty Quest Fleet Agent, leaves unsupported arbitrary
foreground observation unknown, and sends signed proposals to an
already-enrolled Hub. Fleet ingress verifies its device enrollment and key
binding, then uses the exact pinned Manifold adapter for peer-status review;
the two state transitions are committed transactionally or rejected together.
ADB remains an optional validation and maintenance route, not the base
monitoring transport.

QuestIonAble File Manager is a preferred local provider only for the closed
typed operations it advertises and confirms through exact-target readback.
Rusty Fleet uses a different managed request and receipt contract. A portable
workflow intent may feed either private resolver, but it contains no local
path, serial, target, credential, approval, coordination, or Manifold state.

For tracking, the active OpenXR app obtains fused poses and routes generic
relation snapshots through Lattice contracts. ADB, shell helpers, background
services, and Manifold do not become alternate OpenXR tracking owners.

For media, keep accepted Manifold session/stream references separate from
platform lifecycle and high-rate bytes. Source, processor, route/socket
provider, codec, sink, display adoption, and cleanup remain explicit owners.
Do not put frames, depth, meshes, poses, or GPU buffers into settings JSON,
Android properties, or generic command/status payloads.

## Activation And Operator Surfaces

Native OpenXR/Vulkan and Meta Spatial SDK features in Rusty Quest are explicit
opt-ins. Source availability or registration does not activate packaging,
permissions, runtime profiles, scene graphs, input routes, marker streams, or
media paths. Activation requires the current project feature lock plus an
approved runtime input and an effective consumer receipt.

Every accepted Hostess or WPF operator action needs a CLI or local API route
with the same parameters, authority checks, and structured evidence. UI
handlers collect input and project results; they do not own hidden ADB setup,
device mutation, command policy, or evidence reduction.

## Legacy Compatibility

Public Rusty XR remains historical source provenance and an explicit
compatibility/reference lane. Preserve required attribution in `NOTICE.md`, but
do not use Rusty XR repository links, `RustyXr.*` project paths,
`rusty.xr.*` schemas, `/rustyxr/...` routes, or Makepad markers as the active
path for new Morphospace work.
