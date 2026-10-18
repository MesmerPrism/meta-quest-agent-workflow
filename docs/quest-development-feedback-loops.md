# Quest development feedback loops

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
| Native library, Java/Kotlin/Rust lifecycle, new resources or ABI | Build the affected owner artifact; general code replacement has not been established by graphics reload |

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
