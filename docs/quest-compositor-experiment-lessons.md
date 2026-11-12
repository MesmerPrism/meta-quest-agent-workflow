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

## Separate native caller contexts

A bounded v209 diagnostic used an ordinary Shell native executable to load the
manager library by basename and resolve `createRuntimeIpcManager`. Public
`dladdr` attributed the resolved address to `libripcmanager.oculus.so` and that
symbol, at object-relative offset `0x3110` for the selected file. The helper
returned without invoking the factory. Genuine client exit/reap, complete raw
EOF, independent original-process birth absence and owned-stage removal were
observed; post-probe app NoMedia and preservation checks also passed.

Keep that result separate from an earlier JNI caller's `clns-2` load refusal
and a different client's initialization abort. Caller executable, class-loader
and linker context can change the result; Shell UID alone does not establish
equivalence. Bind the exact firmware, executable, library bytes, symbol and
caller for each observation. Host fake-loader tests qualify their own contracts,
not device loadability. These observations are research evidence, not a
published helper procedure or a portable private-API recipe.

An address-owner query identifies the object containing the address; handle
symbol lookup may resolve through dependencies. It does not establish the
top-level handle's object identity or hash the mapped bytes. Preserve the
original loader error before another loader query and copy borrowed metadata
immediately. See the dated Bionic [address-owner implementation](https://android.googlesource.com/platform/bionic/+/android-14.0.0_r1/linker/linker.cpp#2228).
No factory, VM, client initialization/connection, camera or pool call was made
in this diagnostic. Constructor and remote effects remain unknown. Local
retirement proves neither normal MR-client shutdown, image access, namespace
equivalence nor the cause of either earlier failure.

A later single-case Shell-native diagnostic went one step further: a factory
call requesting version 8 returned a non-null opaque object, and the paired
destroy export returned. The selected caller source passed that returned object
to the destroy export; this is source-consistent caller evidence, not an
independent observation of callee arguments or an acknowledgment of object
destruction. Both the manager and retained lazy-module file metadata and hashes
were stable across the case. That file evidence does not hash mapped bytes or
establish the identity behind a top-level loader handle.

The original child genuinely exited with complete raw EOF and reap; independent
kernel birth absence and owned-stage removal were observed. Post-case app
NoMedia, identity, route and unrelated-helper preservation checks passed. No VM,
client initialization/connection, pool, Surface, camera or image operation was
requested. Constructor and remote effects remain unknown, as do remote
retirement, namespace equivalence and the earlier client's failure cause. A
returned destroy export is a distinct evidence level from server completion or
normal client shutdown. This bounded research result supplies no supported
private-API procedure or capture capability.

A subsequent single-case Shell-native diagnostic on the selected v209 firmware
called `ipc_Initialize` with the source-bound 88-byte initialization structure
and a null Java VM. It returned `0`; exactly one paired `ipc_Shutdown` call then
returned the vendor runtime-stop boolean as true. This establishes that a Java
VM was not required for this observed initialization-only path. It does not
establish a VM-free client, connection, Surface or camera API contract.

The original native child genuinely exited with full raw EOF and reap;
independent kernel-birth absence and owned-stage removal were observed. The
selected RIPC, manager and retained lazy-module files had stable stat/hash
bookends. Both application SDK actors remained absent, and installed bytes,
UIDs, identity/enrollment data, grants, routes and unrelated helper state were
preserved. No explicit client registration, client-info request, group-zero
observation, pool, Surface, camera or image operation was requested; no identity
spoofing or namespace override was used.

The returned vendor boolean is not evidence that every global or Binder worker
joined, or that a remote service acknowledged shutdown. Mapped-byte identity,
remote effects, the earlier client's failure cause and equivalence to a JNI
caller remain unproved. Source/ABI analysis, host fake tests, actual export
returns, local retirement and inspected pixels are separate evidence. This is
a bounded research observation, not a supported private-helper procedure or a
capture capability.

A later connection-only case on the selected v209 firmware used an ordinary
Shell native executable with the same null-VM initialization contract. Init
returned success; one client registration returned a nonzero handle and one
connected-status query returned true. The normal disconnect export returned,
and the paired shutdown returned the vendor runtime-stop boolean as true.
Genuine original-process exit, full raw EOF/reap, independent kernel-birth
absence and owned-stage removal were verified with preservation checks.

This establishes bounded native registration and status without a Java VM for
that caller. It does not establish metadata delivery, group permission, an
image-pool grant, camera/image access, ordinary APK admission, namespace
identity, remote acknowledgment or a global-worker join. Earlier unknown
outcomes remain unknown; normal export returns and local retirement are
separate from service completion.

## Metadata interfaces are research boundaries

Source-only analysis of selected shipped firmware identified a named RIPC
metadata lookup and C Begin/End read-lease route as a research lead. Its opaque
32-bit state identifier is neither a client handle nor an operating-system file
descriptor. Group-zero metadata and image-pool permission are separate gates;
an image identifier in metadata is not an acquired image buffer.

The observed Begin path can publish an opaque context even when its data return
is null. A false End result can follow release of the read pin. Interface
release is a different operation and does not replace ending a read lease.
Return-value guesses can therefore omit required cleanup or repeat it. The
selected interface ABI version was 1, distinct from reflection cap 2; never
substitute an assumed interface ABI 2. These findings do not qualify a new
caller, its failure cleanup or a decoder, and provide no executable procedure.

The actual connection-only observation above does not close metadata delivery
or image-method admission. Source-only tracing also identified a real getter
that writes eight metadata-group booleans after checking a connected client.
Those sequential observations are not an atomic grant snapshot or the separate
MR image-method permission. No runtime getter result is established here.

The metadata failure-cleanup/decoder contract, generated image-response codec
and unclaimed broker-FD cleanup remain unresolved. Keep these source findings
separate from actual registration, inspected pixels and earlier unknowns.

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
