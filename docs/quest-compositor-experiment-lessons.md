# Quest compositor experiment lessons

These are development observations from selected shipped firmware and owned
diagnostic components, not a promise of a portable public API. Use the
[capture taxonomy](capture-source-taxonomy.md),
[OpenXR boundary](openxr-tracking-boundary.md) and the selected effect owner.

## Distinguish the source and output

Keep ordinary Android/compositor capture, raw camera pixels, OpenXR app
surfaces and true compositor passthrough separate. A camera texture displayed
on a Home panel is useful live output, but it does not establish stereo-correct
passthrough replacement, geometric equivalence or processing of another app's
framebuffer. A full-view rectangle does not itself provide the right optical
mapping. Compare source dimensions, crop, viewing angles, eye mapping and pose.

Genuine shell experiments demonstrated metadata access, camera streaming,
native compositor capture, own overlay placement and selected native
postprocess effects. Each had different source/caller/lifecycle conditions.
A native capture interface discovered by service enumeration required a
non-null session identifier; a null identity caused a runtime failure. Closed
adapters should encode the actual validated request, not expose a general
private method/argument pass-through.

A selected shipped capture-service trace connected a caller's `Surface` through
`ANativeWindow` to the compositor capture output. That identifies a destination,
not the sampled image. Static GL/Vulkan pipeline construction and program-stage
realization do not establish per-frame image bindings, draw submission, GPU
completion or direct access to the original MR camera source. Keep each of
those joins separate from runtime observations and output-pixel comparisons.

An existing-service peek with typed version reads can be a bounded admission
probe when its exact installed-APK code-only AIDL loading, genuine Shell context
and actual permission checks are preserved, without starting/binding the service
or creating capture. A successful host compile does not prove runtime access.
Inspect the full helper entrypoint: a producer that reads the version and then
selects modes or starts capture is not a read-only probe.
Historical `ImageReader`/`AHardwareBuffer`/fence consumer proof remains qualified
to its firmware, caller, producer and lifecycle; it does not automatically
transfer to newer firmware or an ordinary APK.

## Own resources and feedback

A returned opaque native `jlong` may be a valid nonzero negative value. Do not
reject it with a positive-number test or reconstruct/truncate it; pair the exact
owned token with its supported release. Standalone native registration and
defining-class-loader lifetime are independent from permission acceptance.
Original child EOF/reap and server/token/resource retirement are separate
observations.

Excluding only the root of an own output hierarchy did not exclude its actual
buffer children in a tested capture route. A later test applied all five owned
Android surface controls and still captured the output chart. Repeating those
child-flag hypotheses is therefore insufficient for that route. A different
native OpenXR projection-exclusion path then passed Photo and video
include/exclude/include comparisons, preserving room imagery while removing
the owned chart. Verify the particular source and output exclusion before
enabling a live feedback effect; do not generalize either result to all capture
paths or hide/filter foreign surfaces. Off-headset encoding has a different
feedback boundary from an in-headset mirror.

Texture updates, callback delivery and buffer release need a real lifecycle
owner. Stopping a socket worker by a timed join and clearing its reference can
leave the worker alive. Preserve held/unknown state and reconcile the original
worker rather than allowing another overlapping start. Avoid global capture
stop operations unless their real ownership contract permits the effect.

In one inspected capture-service route, Stop queues a global command through a
void lower interface. Its submission/error reply does not acknowledge later
server consumption or GPU/Surface retirement. Client EOF, joined workers, a
post-return grace period and local `Surface`/`ANativeWindow` release each prove
only their own lifecycle step. Retain server retirement as unknown until the
selected route supplies request-correlated post-consumption completion evidence;
this finding does not rule out a different API providing such a contract.

## Native effects and wearer evidence

Selected native compositor shader paths produced visible binocular effects on
the whole composite outside the application, potentially including UI. This
is not an exported passthrough-only texture. Readback, enable state and cached programs
needed separate handling: writing a new shader file did not prove a cached
program recompiled. Normal compositor suspend/resume appeared to recreate
programs in the tested path; that is a qualified lifecycle lead, not permission
for arbitrary service resets or a general hot-reload guarantee.

For black shader output, isolate the sampled RGB with a finite opaque-output
control before changing layer routing. Zero alpha need not mean unusable RGB;
an effect's alpha gate can discard room color already present in its input.
Qualify alpha and premultiplication against the selected input contract. A
composed packed side-by-side input containing room RGB can support a visible
effect without establishing raw sensor access, calibrated stereo/FOV, an
app-exportable texture or the identity of upstream YUV resources.

Screenshots missed a wearer-visible right-eye edge artifact. Disabling timing
collection and an earlier slice briefly stabilized a single-pass experiment;
the full graph still flickered. Later, one-main-native-slice topology with
GL at 90 Hz and the full three-pass graph removed ordinary tearing for the
wearer while residual flicker remained. A subsequent wearer observation tied
that residual flicker to the rear recenter-relative region; recentering moved
the affected region. The earlier brightness correlation was confounded;
the timing cause remains unproved. This does not invalidate the observed
topology improvement or establish that timing is irrelevant.
Preserve that late evidence and the unresolved cause.
Use actual head turns, recenter-relative regions and affected app/overlay states
when that phenomenon is the question. A forward screenshot cannot close it.

A one-pass native path working does not qualify a two-pass path. An identity
two-pass attempt reproduced a native framebuffer failure; another buffered
Vulkan attempt failed first at external-format sampler compatibility, with a
later GPU loss during cleanup. Preserve the first error and separate later
cleanup consequences. Do not promote those candidates as reusable completed
effects or attribute all failures to the same cause.

## Reusable destination

Keep raw runtime probing as a developer capability with exact firmware and
caller evidence. Extract a Quest source/processor/output/cleanup component only
after its ownership and completion are understood; Hostess can control and
project its evidence. A Kiosk utility demo may expose a qualified developer
route explicitly. It does not establish ordinary APK privileges, broad
cross-app capability or store eligibility. See
[module integration](quest-learning-integration.md).
