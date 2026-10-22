# Quest development feedback loops

For Quest/Rusty hotload, reload, live-edit or avoid-rebuild questions, including
Java, Kotlin, Compose, JNI and Rust, consult this guide and the relevant
capability evidence before the selected app's loader, ABI and lifetime
contract. A current loader limit is not a universal platform impossibility.
Keep three states explicit:

- **Supported by the selected installed loader:** use its actual enabled
  channel, accepted input, ABI and effective adoption evidence.
- **Demonstrated or documented elsewhere:** name the mechanism, version and
  evidence; app integration or an enabling build is still needed before
  claiming support in the selected app.
- **Extension still to investigate:** retain the legitimate build/restart
  fallback; a proposed loader is neither installed support nor a proven loop.

This question route adds no mandatory per-build test or documentation gate.

Choose the smallest existing replacement boundary for the change. This guide
records lessons from device experiments; it does not add a startup checklist or
require hotloading for ordinary development.

| Changed component | Useful existing loop |
| --- | --- |
| Host parser, observer or evidence projection | Qualify the changed caller and select it at its supported handoff; retain the installed app where compatible |
| Supported app parameter | Use the original UI's typed handler and effective status; a settings change does not need a new APK |
| Compatible SDK vertex/fragment arithmetic | SDK graphics reload after one explicitly enabled developer build |
| Mapped authored asset | Register the external mapping before first load, replace the selected content and inspect its effect |
| Explicitly supported compute slot | Use that slot's ABI, activation/fence and state contract; a diagnostic slot is not the private main kernel |
| Native/JVM/ABI change unsupported by the selected installed loader | Use the affected-owner build/restart fallback; inspect the capability evidence below before treating it as a platform limit |

## Capability and experiment evidence

The retained experiments include SDK graphics and mapped-asset replacement
with visible adoption and revert. A compute/SPIR-V replacement also reached a
running pipeline; this does not establish replacement of a native Rust library.
Parameter or policy reload needs its own supported app handler. Neither a
settings change nor shader reload can supply missing JVM methods.

Android mechanisms have different boundaries (checked 22 October 2026):

| Mechanism | Evidence and limit to check before app integration |
| --- | --- |
| Apply Changes | Eligible debug deployments can update code/resources with process or Activity retention depending on the action. [Android's guide](https://developer.android.com/studio/run#apply-changes) still performs build/deployment work; this is not a no-compilation claim. |
| Enhanced Apply Changes | [Studio 4.1](https://developer.android.com/studio/releases/past-releases/as-4-1-0-release-notes#apply-changes) documents adding methods on Android 11 Developer Preview 3 or newer. [Studio 4.2](https://developer.android.com/studio/releases/past-releases/as-4-2-0-release-notes#apply-changes) adds static final primitive fields on Android 11+ and resources with Apply Changes and Restart Activity. |
| Compose Live Edit | Its [own requirements and limits](https://developer.android.com/develop/ui/compose/tooling/iterative-development) cover supported function-body edits in debuggable API 30+ processes, not new methods/signatures or arbitrary structural changes. A first edit in a file resets state. Do not apply these limits to every Android mechanism. |
| Versioned DEX or native module seam | A prospective app integration, not a demonstrated selected-app route. A resident JNI host and versioned C ABI/Rust module would need explicit activation, state, lifetime and reversal contracts. |

Verify the actual device, toolchain, debuggability and edit shape. Method,
class, field and resource changes are mechanism/version dependent; do not
blanket-classify them as requiring reinstall. Apply Changes and Live Edit need
separate clean sessions because their modified-session states are incompatible.
For an installed fixed-JNI/process-lifetime owner without a qualified replacement
seam, the affected-owner build/restart remains the supported fallback.

An earlier retained Compose attempt refused a generated class during compilation,
before device patch delivery. Later preparation kept 22 class names stable and
restored compiled bytes, but proved no successful headset patch/revert. A later
secondary-ADB launch was denied before execution; this is neither device-failure
evidence nor authority to retry through another route. Preserve compiler-shape,
transport, activation and runtime observations separately.

## SDK graphics source reload

The Rusty Quest spatial hotload app already owns
[`FRESH_SDK_GRAPHICS.md`](https://github.com/MesmerPrism/rusty-quest/blob/main/apps/spatial-worldspace-hotload-android/FRESH_SDK_GRAPHICS.md)
and its preparer. Select `-SdkGraphicsHotReload` in the applicable builder and
verify the selection in the actual build input lock. Packaging a preset catalog
does not imply that the fresh-source SDK receiver is enabled. Keep the feature
debug-only and off in ordinary/release products.

Use the enabling APK's exact baseline catalog, material layout, descriptor and
stage interfaces, SDK headers, compiler, optimizer and variant configuration.
Material layouts differ between consumers; an earlier working diagnostic batch
is not automatically compatible with a later product. Compare emitted optimized
SPIR-V, not just source declarations or an unoptimized reflection result.
An optimization may remove fields or change the reflected shape; qualify the
actual selected pipeline rather than weakening its interface check.

Prepare a fresh immutable batch, validate the actual required vertex/fragment
names and aliases against the packaged manifest, and retain exact baseline
bytes for revert. The existing owner preparer and contract define the file set;
do not hardcode a variant count from a different SDK/build. Compilation or ABI
failure stops before upload. Use the current package's guarded upload route,
verify the complete remote batch, then send the existing package-scoped SDK
reload notification once. Uploads are non-atomic and the stock development
receiver is not an authenticated product command surface.

Keep process birth, Activity/app-scene, material/mesh identities, producer,
parameters and output conditions comparable. A successful SDK invocation or
logged reload commit has no pixel/GPU-completion callback. A tested first
capture still showed the old shader before a later capture showed adoption:
observe the original request rather than replaying the trigger because an
early image is unchanged. Inspect the intended effect and exact baseline
restoration in the captured views. Steady-state timing follows adoption and
warm-up; reload/compilation time is a separate measurement.

For shader bisection, retain a known-visible baseline and change one suspected
boundary at a time. A faster black scene is a correctness failure, not a
performance result. Package the accepted shader through the ordinary build
and confirm a fresh launch when closing the product change.

## Assets, topology and scene ownership

An authored asset reload failed until its relative path and APK URI were
joined by an explicit external mapping installed before first entity load.
The corrected route visibly changed positions, material and later topology,
then restored exact source bytes in the same running app. Association count
and SDK callback fields alone were not the visual oracle.

Another tested SDK route changed requested mesh handles/counts while the
retained object kept its old visible geometry. A fresh object created with the
same cached expanded mesh did show the expansion. This narrows the failed
binding boundary; it does not prove an internal SDK cause or make every
retained-object update unusable. Reuse that discriminating comparison before
repeating identical setters. Cache/object retention during shrink is not
resource reclamation.

Keep diagnostic controllers and material references scoped to their owning
Activity/app scene. An actual recreation test found a stale diagnostic holding
materials from the finished scene; correcting ownership restored repeated
recreation. An SDK handle observed in that test was an application pointer,
not a unique scene-generation token. Use actual lifecycle/resource observations
for the claim being made rather than assuming a numerically equal or changed
handle establishes allocation/destruction.

## Measure the useful loop

Record edit start, compile, transfer, trigger, observed output, human/automated
inspection and any required restore separately. Nested clocks are not additive.
Move static preparation, imports and cleanup arguments before fresh admission;
execute deadline-sensitive transitions in ordinary code without model turns
between them. Treat estimated duration as an investigation signal while
preserving actual expiry and unresolved mutation outcomes.

Use stable project/configuration cache lanes and fresh final outputs from the
[APK build lanes](quest-apk-build-lanes.md). Preserve source, signing identity,
required receipts and useful warm caches. Retire only explicitly owned obsolete
generated descendants after actual child EOF/quiescence; file age, a temporary
name or logical directory size does not establish safe or physical reclamation.

For lifecycle/retention claims use [memory profiling](quest-memory-profiling.md).
For automated interaction use [Meta XR Operator](meta-xr-operator-input-automation.md).
