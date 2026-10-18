# Meta XR Operator input automation

Use this optional development route to exercise an application's original
hand/controller interaction. It complements the same-handler CLI/API contract;
a simulated click does not fill a missing semantic command adapter.

## What was demonstrated

On a real native OpenXR Quest application, simulated hand pinch advanced the
original panel, controller handover advanced the next page, button shortcuts
worked and a controller click on the original Save/exit widget completed a
recording with normal writer/producer/XR shutdown. Synthetic joint delivery
did not by itself produce rendered hand meshes. The success is specific to
the selected app, layer, firmware and route; it is not generic input injection
into arbitrary installed applications.

A later SDK run established advancing same-session frames, delivered synthetic
hands and a tracked simulated controller pose. SDK widget adoption and rendered
hand appearance remained separate unproved observations. Do not let an earlier
packaging/host failure erase that later delivery result, or transfer the native
application's demonstrated widget effects to the SDK.

The [tooling guide](meta-horizon-mcp-and-hzdb.md) describes Meta's app-scoped
API-layer/tool boundary. The layer belongs to the target APK composition.
Retain the official layer bytes and its actual build/runtime provenance.
A sidecar or discovered tool catalog cannot retroactively attach it to an
unmodified APK or prove that a focused target session accepts the tool.

## Package the selected route

Check the actual merged and packaged manifest plus runtime native-library
location. One SDK build included the layer in the ZIP but disabled extraction,
so the layer's relative library path did not resolve. A selected debug-only
packaging correction made the layer load and begin its focused XR session.
ZIP membership was insufficient evidence; ordinary packaging remained separate.

Optional composited capture also needs its Java/AAR classes in the target DEX.
A missing capture manager was independent of native layer loading. Qualify
backend and input without making optional capture integration a prerequisite;
if capture is selected, retain genuine MediaProjection consent semantics.

## Prepare and observe a real interaction

Before fresh target checks, prepare the proxy/client, imports, persistent
runtime bindings, exact arguments, release actions and ordinary app exit.
Rehearse changed orchestration in the actual host runtime with inert callbacks:
child-Node success did not catch a persistent-REPL binding failure, and generated
functions were unavailable in another rehearsal. Preserve those failures as
host failures rather than device-input denials.

Use the tool endpoint shape actually required by the selected Meta bundle.
An observed proxy needed the bare origin rather than an assumed path suffix.
Then confirm a live backend and same focused session, not merely advertised
tools. A latest-frame query may repeat a valid snapshot: when cadence is slow,
use bounded successful read-only observations to establish strict same-session
advancement. A failed/unknown request is not a successful observation to retry
blindly. Keep host, device and XR timestamp domains distinct.

Exercise one original action and correlate input delivery with its actual
page/widget/command effect. Test nonzero controller poses and the selected
press-edge semantics; a mouse/ADB tap does not establish Touch parity.
Prepare to release the actual buttons/overrides using supported tools and
retire the owned layer/session. An open hand is not proof that all overrides
were disabled. Record owned proxy exit, target lifecycle and any unresolved
callback/override separately.

For terminal actions inspect durable output, original request identity where
available, writer close, producer acknowledgement and XR teardown. A local
widget need not expose remote command IDs; do not invent them or equate process
absence with a completed save. Repeated sessions can reveal pending-Arm and
late-callback races missed by a first-session pass.

## Reuse destination

Keep layer packaging and on-device platform input integration in Rusty Quest,
with app action semantics in the application owner. Hostess can expose the
existing host adapter and evidence through its CLI/WPF surfaces. Keep tool
version, app/session identity, delivered input, effective action, visual hand
appearance and capture result as separate observations. See
[module integration](quest-learning-integration.md) for the shared-library split.
