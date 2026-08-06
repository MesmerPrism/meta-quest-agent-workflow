# OpenXR SDK, API Layer, And Tracking Boundary

Fused HMD and controller pose belongs to the active XR app's OpenXR session.
ADB, a shell helper, a broker, and a 2D Android service are useful around an XR
app, but they are not a supported public route to another process's fused
tracking stream.

Keep these integration shapes distinct:

| Shape | What it can do | Boundary |
| --- | --- | --- |
| App-owned native OpenXR | Own the instance, session, spaces, actions, swapchains, and frame loop. | The app owns lifecycle and semantic behavior. |
| Co-resident engine bridge | Reuse documented engine or SDK handles to call compatible OpenXR functions. | Reuse the existing lifecycle; do not start a competing frame loop or assume every extension was enabled. |
| OpenXR API layer | Intercept, observe, modify, or insert calls between the app and runtime. | It runs in the app process, is selected at instance creation, and sees OpenXR rather than the engine's semantic scene model. |
| External sidecar | Send bounded typed requests to an app or prepackaged layer over authenticated IPC. | Termux, Binder, localhost, and MCP are transports or clients, not OpenXR or command authority. |

## API Layer Capability

The OpenXR loader supports API layers. A layer can wrap a core or extension
entrypoint that it negotiates, call the next layer or runtime, keep handle-
scoped state, modify arguments or returned values, and expose named extension
functionality. It sees only the calls that traverse its negotiated call chain.

Useful interception surfaces include:

| Concern | Representative calls | Practical use |
| --- | --- | --- |
| Instance, system, session, and events | application `xrCreateInstance` routed by the loader through layer `xrCreateApiLayerInstance`, then `xrGetSystem`, `xrCreateSession`, and `xrPollEvent` | Capability inventory, lifecycle diagnostics, and structured observations. An API layer does not implement `xrCreateInstance` itself. |
| Frame timing and composition | `xrWaitFrame`, `xrBeginFrame`, `xrEndFrame` | Observe frame state and submitted composition-layer metadata. Do not create a second frame loop. |
| Views, reference spaces, and action spaces | `xrLocateViews`, `xrCreateReferenceSpace`, `xrCreateActionSpace`, `xrLocateSpace` | Observe or substitute app-visible poses with exact time, base-space, and validity handling. |
| Actions and controller state | `xrCreateAction`, `xrAttachSessionActionSets`, `xrSyncActions`, `xrGetActionState*` | Inspect the app's action map or apply bounded app-visible overrides under an app-owned contract. |
| Haptics | `xrApplyHapticFeedback`, `xrStopHapticFeedback` | Observe or filter app requests. New haptics still need a valid action, binding, focused session, and explicit policy. |
| Swapchains and graphics binding | `xrCreateSwapchain`, image acquire/wait/release, graphics extension calls | Observe image lifecycle and formats. Pixel access still needs graphics-API-specific synchronization and image access. |
| Runtime or vendor extensions | Hand tracking, passthrough, environment depth, spatial entities, and other enabled extensions | Resolve only extensions enabled and supported for the active instance/runtime. Preserve permission and consent boundaries. |

An input override is visible only to an application whose relevant calls pass
through the layer. It is not physical controller input, does not change Horizon
OS globally, and may not affect another input path. Maintain explicit human-
versus-synthetic arbitration and a fail-safe release path.

OpenXR has no generic panel, button, entity, or engine scene-graph semantics.
The app must supply any semantic action contract; the layer must not infer
authority from raw handles or caller-selected command names.

## Android And Quest Loading Boundary

For an ordinary Android app, package an API-layer library for the target ABI
and its JSON manifest in the target APK. The OpenXR loader discovers app
manifests under:

```text
assets/openxr/1/api_layers/implicit.d/
assets/openxr/1/api_layers/explicit.d/
```

The layer chain is established during `xrCreateInstance`; a normal sidecar
cannot attach a new layer to an already-created instance. Android also defines
system API-layer directories, but installing there and loading their libraries
depends on the device image, linker namespaces, filesystem policy, and SELinux.
An ordinary Quest or Termux app must not claim that privilege.

Consequently, app-owned development APKs can deliberately package a layer. An
ordinary developer app cannot inject one into arbitrary installed Store apps.
Repacking another APK also changes its signing and distribution identity and
is not a supported generic accessibility route.

## Co-Resident Engine Or Spatial SDK Bridge

Use a co-resident bridge only when the engine or SDK documents a supported
route to its current OpenXR handles or compatible function dispatch. The bridge
may then call functions enabled for that same instance and session without
creating a competing loader, instance, session, or frame loop.

Keep lifecycle ownership explicit. If the engine or Spatial SDK owns frame
wait, begin, end, and composition submission, the bridge must not run another
sequence. Record which extension was enabled, which function resolved, which
reference space and time were used, and which owner submitted the final layer.

An API layer is complementary: it can observe only the calls that traverse its
intercepts. Use a documented bridge for app semantics and a layer for bounded,
engine-independent inspection or interposition.

## No MCP Requirement

MCP is optional transport. A custom layer can consume accepted low-rate state
from an in-process API, Binder service, authenticated localhost endpoint, or
shared-memory adapter. Do not expose raw OpenXR calls, arbitrary handles, or a
generic injection command. The owning app defines bounded semantic operations,
and Manifold owns command, lease, replay, revocation, and control-transport
authority when that route is used. Termux remains a client.

The layer may report the values it intercepted and returned. The participating
app or Quest adapter owns the effective receipt that binds those observations
to app behavior. Keep high-rate pose, depth, image, and mesh data out of generic
command JSON.

## Inspection Before Implementation

Use the Khronos loader and open-source API layers as implementation references:

1. Inventory the target app's enabled layers and extensions without a device
   mutation.
2. Start with the Khronos API-dump or validation-layer structure rather than
   informal function hooking.
3. On desktop, chain a tracing layer above or below another explicit layer to
   compare app-facing and runtime-facing calls; layer order is significant.
4. Record handle creation and destruction, inputs, returned state, timing,
   validity flags, and the exact layer order.
5. Use Meta XR Operator only as an experimental black-box behavior reference.
   Its MCP tool schema is not its native implementation contract.
6. Reproduce only the bounded behavior needed by an app-owned typed contract.

This path does not require disassembly of a proprietary binary. Review the
selected package license separately before any binary analysis.

## Correct Ownership

The foreground XR app should:

```text
create the OpenXR instance/session
select reference spaces
poll actions
locate views and action spaces at the selected XrTime
record validity/tracked flags
submit layers
publish any app-owned diagnostics
```

If another local process needs tracking snapshots, build a thin adapter in the
foreground XR app:

```text
OpenXR frame loop
  -> locate views/actions
  -> sanitize and timestamp sample
  -> publish over app-owned UDP/TCP/WebSocket/broker route
```

## What ADB Can Test

ADB can test Android-level routing:

```powershell
adb -s <serial> shell input keyevent KEYCODE_BACK
adb -s <serial> shell input tap <x> <y>
adb -s <serial> shell input text <text>
```

These are not proof of Meta Touch controller action bindings or OpenXR input.

## Readiness Signals

OpenXR render readiness usually needs app logs or app status markers. Useful
markers include:

```text
OpenXR session running
valid view pose
nonzero XR cadence
frame submitted
source/projection contract logged
visible projection ready
```

Focus alone is not enough. An app can be foregrounded and still fail to render
or receive valid XR poses.

## Primary References

- [OpenXR 1.1 specification: API layers](https://registry.khronos.org/OpenXR/specs/1.1-khr/html/xrspec.html#fundamentals-api-layers)
- [OpenXR loader design and Android layer discovery](https://registry.khronos.org/OpenXR/specs/1.1/loader.html)
- [Khronos OpenXR SDK and API-layer source](https://github.com/KhronosGroup/OpenXR-SDK-Source)
- [Meta XR Operator overview](https://developers.meta.com/horizon/documentation/unity/meta-xr-operator/)
- [Meta XR Operator standalone connection](https://developers.meta.com/horizon/documentation/unity/meta-xr-operator/connecting-ai-agents/)

