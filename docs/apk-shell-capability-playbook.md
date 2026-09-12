# APK-to-shell capability playbook

Use this playbook when an ordinary Quest APK needs a bounded operation from an
ADB-started Android shell process, or when a shell-owned capture helper may feed
an app-owned or Manifold-owned stream. Diagnose identity, bootstrap, transport,
API authority, effect, and cleanup separately.

## Three different privilege contexts

| Context | What it establishes | What it does not establish |
| --- | --- | --- |
| Windows administrator | Host-side UAC elevation for local files, processes, firewall configuration, and ports. | A different Android UID, SELinux domain, capability set, package attribution, or API permission. |
| Android ADB shell | Normally UID 2000 with the Shell package's Android permissions and the device's `shell` SELinux domain. | Root, unrestricted framework access, or permission for every cross-domain IPC route. |
| Android root | Device-side UID 0 when a root route actually exists. Android SELinux can still confine it. | Availability on a retail Quest or automatic success through remaining service, AppOp, and SELinux checks. |

Starting ADB from an elevated Windows terminal does not elevate the Android
process that ADB creates. Record host elevation and Android identity separately.

## Diagnose one layer at a time

1. Record UID/GID/groups, SELinux context, effective capabilities, Android API
   and build, boot ID, PID/start time, and exact helper hash.
2. Check Android package attribution. The package named in an
   `AttributionSource` must belong to the calling UID.
3. Check runtime initialization. A plain `app_process` helper can need a main
   Looper and system `ActivityThread` before framework manager construction.
4. Prove one inert transport under the installed app's real SELinux domain.
5. Bind the transport identity to the intended app UID/signature and one fresh,
   expiring session token. Add negative caller and token tests.
6. Inventory the exact framework API or shell command and all of its permission,
   AppOp, package/UID, role, target-SDK, and SELinux gates.
7. For a mutation, record dispatch and fresh effective-state readback. A return
   value or exit code alone is not confirmation.
8. Prove timeout, peer death, FD closure, provider-lease release, private-state
   removal, and restoration or unchanged-state evidence.

Do not classify `SecurityException`, `NoSuchFieldException`, a null service,
timeout, or connection failure as missing shell authority until the emitting
layer is known.

## Current Quest evidence

The following results were observed on Quest Android 14/API 34 builds with an
ordinary unprivileged test APK and bounded UID-2000 shell helpers. They are
target evidence, not general Android guarantees.

| Route or layer | Observed result | Supported claim |
| --- | --- | --- |
| Shell identity | UID/GID 2000, `u:r:shell:s0`, and zero effective Linux capabilities. Several Shell-package permissions were present. | The tested process was Android shell, not root. Permission presence is not effect proof. |
| App identity and process visibility | The APK ran as `untrusted_app` with its application UID, seccomp mode 2, and zero permitted/effective capabilities. It could read the 36-character boot ID. Reading `/proc/<live-shell-pid>/stat` returned `ENOENT` even while the shell process was independently confirmed alive. | An app-side `/proc` lookup failure can be process-visibility restriction rather than process absence. Use the shell's own identity receipt or an authorized host observation for shell PID/start-time binding. |
| Framework attribution | A system-context Wi-Fi read first failed because package `android` did not belong to UID 2000. A main Looper, system `ActivityThread`, explicit UID-2000 attribution for `com.android.shell`, and a Binder-backed manager then enabled bounded Wi-Fi and Bluetooth state reads. | The first error was bad initialization/attribution, not a demonstrated Wi-Fi authority denial. Reads do not prove mutation. |
| App → shell abstract Unix stream socket | Enforcing SELinux denied `{ connectto }` from `untrusted_app` to `shell` for `unix_stream_socket`. | This direction was blocked before application authentication on the tested build. |
| Shell → app abstract Unix stream socket | Enforcing SELinux denied `{ connectto }` from `shell` to `untrusted_app` for `unix_stream_socket`. | Reversing the direct abstract-socket direction did not avoid the tested policy boundary. Filesystem sockets and datagrams remain separate cases. |
| IPv4 loopback TCP | Both directions completed 50 echo samples and an exact 4 MiB integrity transfer. | Bounded local connectivity and integrity passed. This is not mutual authentication, sustained throughput, energy, latency, or streaming qualification. |
| Binder bootstrap | The shell acquired an exported provider through Android 14's exact external-provider interface, called it with explicit shell attribution, received an app Binder callback, completed an inert token echo, released the provider lease, and exited. The provider observed caller UID 2000; the shell callback observed the app UID. | Synchronous two-way Binder handoff and caller-UID observation passed for the test pair. A token echo is not full mutual authentication or a persistent-service result. |
| Wrong expected app UID | The provider rejected the mismatched UID with `SecurityException`, did not call back, and released the external-provider lease. | The implemented UID check had a meaningful negative result. Package/signature authorization, wrong-token, replay, and unrelated-app tests remain distinct. |
| Initial timeout implementation | The detached helper survived its initiating ADB command and reached its deadline, but a blocked socket-accept worker kept the process alive until exact-owner cleanup. | This was a cancellation defect in the diagnostic, not proof of a platform lifecycle limit or durable-service success. The corrected STOP/watchdog results appear below. |
| Binder-carried pipes | Pipes passed from app to shell and shell to app transferred 4 KiB and 4 MiB fixed patterns with exact hashes and EOF. Provider release was recorded. | Bidirectional bounded pipe carriage, integrity, and normal EOF passed. This is not sustained streaming, backpressure, energy, or in-flight peer-death qualification. |
| Retained Binder status and token negative | Status worked after the initiating ADB command returned and while the activity reported `resumed=false`. A wrong callback token returned `SecurityException: callback_identity`; the following valid status call still worked. | Short background Binder retention and the tested wrong-token rejection passed. This is not a long-background or power-management result. |
| Corrected STOP, app death, and watchdog | STOP terminated the shell helper; the APK then observed Binder death and `DeadObjectException`. Force-stopping only the test APK caused the shell to observe app death and exit. A real three-second watchdog expiry terminated another helper and the APK observed its Binder death. | These bounded lifecycle paths passed for the corrected helper. This row does not cover USB transport disconnection, daemon restart, reboot, long background duration, sleep, or package replacement. TLS route loss and the separate daemon-restart negative appear below. |
| Termux TLS launch and retained Binder after route loss | An attended, headset-local Termux key reached an Android-NSD-selected TLS endpoint after classic port `5555` had been disabled. A normal `RunCommandService` execution had created the ordinary Termux `untrusted_app` ADB server. The USB-connected host then used `run-as com.termux` only to dispatch an ADB client request to that existing server; the UID-2000 helper itself was created through its authenticated TLS target. After Wi-Fi, `adb_wifi_enabled`, and the TLS listener were all off, the same helper PID/start time remained live and the app-local timer completed Binder status plus exact 4 KiB and 4 MiB pipe hashes in both directions. A later listener-absent sample bracketed completion, the TLS target was unreachable, and the `adbd` PID was unchanged. An automatic guardian restored the original association; typed STOP exited the helper and the APK observed Binder death. | One bounded Termux-TLS-launched shell lease and retained Binder/FD exchange survived loss of that Wi-Fi/TLS route. The USB cable remained connected as observer and controller, and the ADB client dispatch used `run-as`; this is not a fully headset-UI-driven run, long-duration or production streaming, in-flight peer-death, daemon-restart, sleep, reboot, or unattended-bootstrap evidence. |
| No-USB BLE Wi-Fi cycle from a Wi-Fi-ADB-launched helper | With physical USB disconnected and independently reported unconfigured, classic Wi-Fi ADB launched a detached UID-2000 helper and the APK reached GATT readiness. The signed sequence authenticated READY, rejected a bad MAC and replay, accepted a no-op, disabled Wi-Fi, kept BLE connected while five TCP probes failed across a confirmed 10.016-second interval, and then re-enabled Wi-Fi. After the original association and Wi-Fi ADB returned, USB was still disconnected, the helper PID/start time and boot ID were unchanged, and the `adbd` PID/start time was unchanged. Shell events recorded UID-2000 disable/enable effects, stopped the guardian before reporting `RESTORED`, and bound every command to the app UID. Typed STOP exited the helper and the app reported stopped. The aggregate harness retained `failed` because a CRLF/LF text comparison rejected the saved-network inventory; raw before/after inventory bytes and hashes were identical. | One bounded BLE control cycle completed without an active USB connection after bootstrap and helper launch over classic Wi-Fi ADB. It proves five failed observations of that TCP endpoint while BLE remained connected plus discrete shell-confirmed Wi-Fi OFF/RESTORED states. It does not prove continuous radio telemetry, absence of every network route, autonomous bootstrap, reboot survival, long duration, or a product control plane. |
| Host receipt parsing | One initial host-side parse was malformed because raw tab characters in UID/GID status values were not escaped as JSON. Raw evidence was preserved, only the private parsed copy was normalized, and the probe sequence resumed; the source was fixed for later builds. | Preserve raw evidence and distinguish a receipt-parser defect from a device or capability failure. |
| ADB-shell display acquisition | One still capture produced a valid 3664×1920 PNG that visibly contained the physical stereo passthrough view and 2D panels. A two-second raw H.264 `screenrecord` at 1832×960 and 8 Mbit/s produced 945002 bytes; 132 decoded frames had 132 unique hashes. Recorder and decoder exited successfully and no recorder remained. | This proves a bounded shell acquisition route on the tested awake display. The raw stream's reported `1200000/1` frame rate is unusable timing metadata, so the run proves no frame rate or latency. It does not prove protected-content coverage, Camera API access, complete XR-layer capture, APK/FD integration, audio, or streaming performance. |
| BLE-authenticated Binder no-op | A signed READY response authenticated the exact run. A bad MAC and a replay were rejected. A valid no-op crossed the APK-to-shell Binder callback and reached UID 2000. Only Bluetooth connect and advertise runtime permissions were granted to the new test APK. | The bounded signed BLE control path, two negatives, and no-op passed for this app/helper pair. This does not grant a general BLE command channel or authenticate an unrelated package. |
| BLE-requested Wi-Fi off/resume | A signed sequence disabled Wi-Fi; USB readback confirmed the effective disabled state while the BLE connection remained active. A later signed sequence re-enabled Wi-Fi; USB readback confirmed enabled state, the original association rejoined, saved-network inventory was byte-equal, and the TCP ADB port remained `0`. Typed STOP terminated the helper. Bluetooth was ON before and after. | One reversible Wi-Fi enable-state cycle passed through the authenticated BLE→APK→Binder→UID-2000 route. This did not switch saved profiles, enable Wi-Fi ADB, test reboot/daemon loss, or prove arbitrary Wi-Fi APIs. |
| Restore guardian | The guardian was armed as an exact UID-2000 child of the shell server while Wi-Fi was off, then stopped and reaped after normal resume. Java PID reflection returned `-1`, while USB process evidence identified the exact child. | The guarded ownership and normal cancellation path passed. Automatic guardian expiry/restoration was not exercised in that BLE test; reflection metadata failure was not a permission result. |
| Detached helper across ADB daemon restart | A read-only detached watchdog became a PPID-1 child and completed its normal 18-second deadline. Repeating the route and then intentionally changing the ADB USB configuration produced READY, followed by no child and no completion receipt. A Wi-Fi restore guardian likewise disappeared when classic TCP ADB was enabled during its run; later direct USB operator recovery restored Wi-Fi. | On the tested build, ADB daemon/configuration restart invalidated these detached shell leases despite reparenting. Configure the required ADB transport before arming a guardian, and do not claim its automatic restore path survived daemon churn. |
| Offline-hosted-network automatic guardian | After ADB configuration was finalized, a separately armed guardian automatically restored the original station network from the offline Windows-hosted network. Saved-network inventory remained exact, the `adbd` PID was unchanged, and no operator restore was invoked. | The automatic restore path passed with stable ADB configuration. This is separate from the earlier BLE guardian whose automatic path was not exercised, and it does not override the daemon-restart negative above. |
| First BLE-cycle attempt | The same APK completed Wi-Fi-off, but the host logger could not serialize a non-primitive BLE connection-state object and therefore did not send resume. Typed STOP plus an eager USB recovery restored Wi-Fi. The logger conversion and STOP settlement were fixed, then the same APK was rerun without rebuilding. | This is a failed attempt with recovery, not a successful BLE cycle. Host receipt serialization must not be confused with device behavior. |
| Final cleanup | Fresh readback matched the original package inventory and original APK hash, Wi-Fi association and saved-network inventory, Wi-Fi and Bluetooth enabled state, Wi-Fi ADB properties, stay-awake state, and ADB forward/reverse sets. All diagnostic processes, recorder, staged files, and the new APK were absent; the coordination lease was released. | The diagnostic restored or preserved its recorded baseline and removed its owned artifacts. |
| Termux TLS run cleanup | After one retained cleanup failure, the corrected cleanup removed both test APKs, their staged files, and their processes; restored the original Wi-Fi association, saved profiles, settings, and ADB forward; and released every coordination lease. The wearer elected to retain the newly installed Termux runtime, Python, Android tools, and its headset-local ADB key. The classic TCP service property began absent and ended at integer `0` because Android rejected clearing that integer property; the listener remained disabled. | The run-owned diagnostics were removed and the recorded functional baseline was restored. The retained Termux toolchain/key and absent-to-disabled-`0` property representation are disclosed deltas, not claims of byte-exact baseline restoration. |

No result in this snapshot proves in-flight peer-death FD closure, sustained
backpressure or streaming performance, saved-profile switching,
capture-to-APK FD integration, protected-content or
complete-XR-layer coverage, long-background/power behavior, reboot, or
USB-transport-disconnection survival. A separate negative shows that daemon
restart can terminate a detached helper. Keep other rows pending until exact
target receipts exist.

## Transport selection

| Route | Identity and policy boundary | Use |
| --- | --- | --- |
| Binder | The receiver can inspect Binder caller UID/PID. A bootstrap provider or another deliberately authorized delivery route is still required. | Preferred typed control plane after caller authorization, death handling, deadline, and teardown pass. |
| Loopback TCP | The loopback address establishes locality, not process identity. | Fallback or measured bulk route with strict loopback bind, fresh mutual challenge, replay rejection, protocol framing, deadline, and cleanup. |
| Direct Unix socket | `SO_PEERCRED` is useful only after SELinux permits connection. Direction, socket type, pathname labeling, and domains all matter. | Do not retry the tested abstract stream route as if direction alone changed its result. Test a different route only for a concrete need. |
| Binder-carried FD | Binder can carry a pipe, connected socketpair endpoint, or shared-memory descriptor, but SELinux FD-use permission and descriptor lifetime remain separate predicates. | Bidirectional bounded pipes passed on the tested build. Qualify socketpair/shared-memory, sustained backpressure, and failure-time closure separately if the design needs them. |

The Android 14 SELinux `binder_call(client, server)` macro combines Binder
`call`/`transfer` with client use of open files received from the server. That
is an AOSP policy pattern, not proof that the relevant Quest app/shell domains
permit both FD directions. Verify each direction and capture AVCs.

## Control and bulk data

Keep typed commands, session identity, start/stop, errors, counters, deadline,
and FD handoff on the control plane. Keep frames and other high-rate bytes on a
bounded FD/shared-memory/socket data plane.

The tested first step passed: pipes transferred 4 KiB and 4 MiB fixed patterns
with exact hashes and EOF in both directions. For a selected product path, still
measure sustained backpressure and FD-count restoration, and interrupt a
transfer while killing each peer in turn. A delivered descriptor is a
duplicated kernel reference: revoking a token does not retract it. Cleanup must
reject new requests and close every owned endpoint.

Use a passed socketpair endpoint only when duplex streaming is needed. Verify a
small exchange, half-close/EOF, framing, backpressure, and cleanup before
measuring throughput. Passing a preconnected endpoint does not prove direct
app-to-shell Unix socket connection is permitted.

Use shared memory only when buffer reuse justifies index, bounds, fencing, and
overwrite rules. For immutable consumer data, reduce protection before handoff
when appropriate. Android `SharedMemory.setProtect()` affects future mappings;
existing mappings retain their earlier access. Unmap buffers and close all
descriptor copies explicitly.

Keep shell display acquisition separate from the app bridge. A valid
`screencap` or `screenrecord` sample proves only that the selected shell capture
route produced those bytes. It does not prove that the Binder FD plane carries
capture output, that protected or every XR layer is present, or that timing is
usable. Follow [Quest capture stack notes](quest-capture-stack-notes.md) and the
[capture-source taxonomy](capture-source-taxonomy.md), retain visual source
identity and dimensions, and measure timestamps/latency through the final
consumer before making a streaming claim.

## Binder bootstrap boundaries

The tested Android 14 shell route used the exact hidden interfaces for external
provider acquisition, attributed provider call, and external-provider release.
Hidden interface signatures are build-sensitive; resolve and record the target
signatures instead of matching a method name alone. Ordinary
`ContentResolver.acquireProvider()` can preserve an internal `android` package
identity and fail UID/package validation even when the explicit shell-attributed
external-provider route works.

Require the provider to verify the Binder caller UID before returning a callback
or FD. Bind that UID to the intended installed package and signing identity.
The shell callback must likewise verify the app caller UID. Treat a nonce echo
as an inert bootstrap check only. The tested wrong callback token was rejected
and a later valid status call remained usable; the later signed BLE protocol
also rejected a request replay. Broader package/signature authorization,
stale-session acquisition, and unrelated-app coverage remain untested. Select
additional negatives in proportion to the claim and exposed authority; they are
not automatic prerequisites for every bounded diagnostic.

## Bounded BLE-to-shell effect sequence

For a reversible radio check, keep BLE in the ordinary APK and the exact
framework/shell effect in the UID-2000 helper:

1. Bind a fresh run token, deadline, expected app UID/signature, request
   sequence, and keyed request/reply authentication to both ends.
2. Require signed READY, a bad-MAC rejection, replay rejection, and a valid
   no-op before arming a mutation.
3. Snapshot Wi-Fi enabled state, current association, saved-network inventory,
   Bluetooth state, and Wi-Fi ADB listener state through independent readback.
4. Arm a separately owned restore guardian with an absolute deadline and retain
   its exact parent/child identity. Do not depend solely on reflective PID
   metadata.
5. Send one Wi-Fi-off request. Confirm effective disabled state over the USB
   observation route and verify the BLE control connection remains alive.
6. Send one resume request. Require signed reply plus independent Wi-Fi enabled,
   association, saved-inventory, Bluetooth, and ADB-listener readback.
7. Send typed STOP and verify the server, guardian, BLE service, and owned files
   are gone or intentionally retained by the evidence owner.

If the host logger fails after a mutation, run the predeclared recovery path
and classify the attempt as failed/recovered. Do not resume the sequence by
editing its evidence. Preserve the raw error, fix the harness, and rerun the
same immutable APK when its bytes did not change.

## Lifetime and cleanup

A helper intended to outlive the initiating ADB command needs deliberate
detachment, closed or redirected standard FDs, an absolute monotonic deadline,
and a stop mechanism that unblocks every listener and worker. `shutdownNow()`
alone does not guarantee that blocking native or socket calls return.

The corrected helper passed initiating-command exit, short background status,
explicit STOP, test-APK death, and a three-second watchdog expiry. The APK
observed Binder death after server STOP and expiry, and the shell observed app
death after only the test APK was force-stopped. A separate read-only watchdog
completed after ordinary detachment and PPID-1 reparenting, but disappeared
without its completion receipt after a controlled ADB USB daemon restart. A
restore guardian also disappeared when classic TCP ADB was enabled mid-run;
later recovery was a direct USB operator action, not the guardian's automatic
path. Establish the needed ADB configuration before arming the helper or
guardian. Test long background duration, sleep/power management, package
replacement, and reboot separately.

A second bounded run separated bootstrap transport from retained capability.
After an attended Termux key and dynamic TLS endpoint were ready, classic port
`5555` was already closed. The host's USB route invoked a `run-as com.termux`
ADB client, which addressed the existing ordinary Termux `untrusted_app` ADB
server and launched the helper through the exact TLS target. The post-drop work
was scheduled through TLS before Wi-Fi was disabled, then executed from an
app-local timer while Wi-Fi, `adb_wifi_enabled`, and that TLS listener were off.
The exact UID-2000 helper PID/start time stayed constant and the retained Binder
carried fixed 4 KiB and 4 MiB patterns in both directions with exact hashes.
The guardian restored the original association without USB radio recovery;
typed STOP terminated the helper and the app observed Binder death. The first
harness attempt retained a 42 ms post-completion listener-bracketing gap and
therefore remained failed/recovered with USB restoration; the corrected rerun
captured the missing post-completion sample and passed. Keep the USB cable and
`run-as` controller disclosure with this result.

A separate classic-Wi-Fi-ADB run removed USB from the live control sequence.
Before the helper was started and after the cycle completed, host discovery had
no physical serial route and Android reported USB disconnected, unconfigured,
and in kernel `DISCONNECTED` state. Classic Wi-Fi ADB launched the same bounded
helper shape. Authenticated BLE then requested OFF, stayed connected while five
TCP connection attempts failed during a measured 10.016-second interval, and
requested resume. After Wi-Fi ADB returned, the same UID-2000 helper PID/start
time and `adbd` PID/start time remained, the original association returned, the
saved-network inventory was byte-identical, and USB was still disconnected.
The shell log placed guardian shutdown before `RESTORED`; typed STOP exited the
helper and the app reported stopped. Preserve the aggregate harness's failed
status: it compared CRLF-decoded command output with LF-normalized text and
stopped before setting its success field. The raw byte/hash comparison and the
other preserved receipts support the cycle without rewriting that failed
receipt.

Record PID/start time/boot ID continuity, Binder death or EOF, listener removal,
provider-lease release, FD baselines, private-state removal, and effective
device state. ADB-mode startup should be treated as lost at reboot until current
target evidence proves otherwise.

## After-reboot bootstrap without an external access point

A retained Binder helper and its BLE control path end at reboot. Creating a new
UID-2000 process afterward is a separate bootstrap problem. Keep three
predicates distinct: an authorized ADB host key, an enabled ADB transport, and
a reachable live listener. Persistence of one does not prove the other two.

On a read-only inspection of one current Quest Android 14/API 34 build, secure
Wireless Debugging obtained `WifiManager.getConnectionInfo()` and rejected the
request unless the current station connection had a valid network ID, SSID or
Passpoint-name resolution, and a nonempty BSSID. A failed check reset
`adb_wifi_enabled` before TLS startup. A Quest-owned Wi-Fi Direct group or
local-only hotspot had already failed this topology on an earlier lab headset.
Treat those behavioral results and the current-headset static inspection as
separate evidence; neither establishes every Horizon release.

A later bounded test on the inspected headset exercised the reported timing-
race shape after an actual reboot. Station Wi-Fi was disabled and a normal test
app held a ready local-only hotspot on a separate interface. One attempt started
the hotspot before the setting pulse; a second started the pulse before and
overlapped hotspot startup. Each pulse issued fewer than 600
`adb_wifi_enabled=1` writes over roughly 15 seconds and restored the prior value
in `finally`. Authorized USB observation covered roughly 36 seconds per attempt.
The setting briefly read `1`, the framework reset it to `0`, and repeated socket
readback found no TLS listener in either ordering. The app-owned hotspot stayed
ready. This is a two-ordering negative on the inspected Quest Android 14 build,
not a universal finding about other race timings, hotspot implementations,
Android versions, or Horizon releases.

The same current inspection found that direct persistence proposals are not a
shell or ordinary-app bypass. The shipped property policy limits
`persist.adb.tcp.port` to `init`, and limits
`persist.adb.tls_server.enable` to `init` and `system_server`. A Shell-package
permission or an app grant to write secure settings does not grant property
service authority.

Meta's companion implementation has two distinct controls. Its ADB-mode worker
writes only the global `adb_enabled` setting, which enables the USB debugging
gate; it does not start ADB over BLE or a TCP/Wireless Debugging listener. Its
wireless-pairing worker writes `adb_wifi_enabled` and asks `IAdbManager` to
enable pairing by code, so it still reaches the framework network-admission
path above. Historical reverse engineering documents a companion BLE protocol
with ADB- and developer-mode controls. That artifact does not demonstrate an
unauthenticated or network-listener bootstrap.

USB ADB from a previously authorized host remains the established AP-free
bootstrap. On the inspected headset, the authorized USB shell temporarily
enabled classic TCP ADB, the existing Termux ADB server connected over loopback,
and the wearer approved that client's distinct RSA key through Meta's visible
debugging prompt. The Termux client then returned exact UID 2000 over classic
loopback. While classic TCP remained enabled, the same client key also returned
UID 2000 through a fresh dynamic Wireless Debugging TLS endpoint on an eligible
station network. Later cleanup removed both transports. This establishes an
attended key bootstrap and a successful exact-target TLS connection, but does
not establish an exclusive TLS-only runtime, an authorization bypass, or
unattended post-reboot recovery.

Android NSD supplied the successful dynamic TLS port even though the packaged
Termux Android Tools build intentionally omits ADB-host mDNS integration. Its
direct host-and-port pairing, TLS, and RSA implementation remains present. The
runtime `service.adb.tls.port` property was blank while the listener and exact
UID-2000 session were live on this headset, so do not use that property as a
required positive or negative witness. Require current Android NSD or socket
evidence and the independent exact-target shell-UID gate.

A phone or laptop hotspot with no Internet can satisfy the station-network
shape, but it is still an external access point. Shizuku and LADB can consume a
working on-device Wireless Debugging service; reports show that the Quest
pairing UI varies by Horizon version. A separate Android 16 Pixel report used
repeated UI actions to race Wireless Debugging shutdown while the phone hosted
a hotspot. It remains version- and timing-sensitive research rather than a
supported Android feature, and it does not bypass pairing. The two bounded
orderings on the inspected Quest Android 14 build were negative. Bluetooth PAN
could carry an already running classic ADB listener if Quest exposed the profile
and route, but no reviewed source shows it enabling that listener or creating
shell authority.

## Offline Windows hotspot evidence

For implementation locations and reproduction order, use the
[collaborator handoff](offline-hotspot-shell-ble-handoff.md). Its source map pins
the Windows, Quest, and Termux implementations separately from these empirical
claims.

A tested Windows Wi-Fi Direct autonomous group owner with legacy access-point
support provided a Quest station connection without Internet sharing. The
Quest obtained an address, completed a nonce exchange with a listener bound to
the group-owner interface, and exposed a fresh TLS endpoint through Android NSD
after the wearer accepted Meta's network approval. The retained Termux client
key connected without a new RSA-key prompt; its exact-target boot identity and
shell UID 2000 matched the USB-observed headset. Classic TCP remained enabled
during this TLS check, so the result establishes the offline hosted station
network and exact TLS target, not an exclusive TLS-only runtime. The helper did
not request a Fleet start. External IPv4 and IPv6 HTTP controls passed on the
original network, failed on the temporary network, and passed again after
restoration. Host readback showed sharing and forwarding disabled; the host
retained its original upstream association. These are local connectivity,
retained-key TLS reuse, and tested Internet-isolation results, not automatic
post-reboot recovery, streaming throughput, or an exhaustive firewall
assessment.

The accepted TLS listener was not durable through the whole attended window.
About two minutes after the successful status, the framework logged a network-
disconnect event and disabled Wi-Fi ADB; the TLS listener stopped without an
`adbd` process restart. The Quest was later again associated with the same
hosted network while the host group owner remained live, and there was no
observed user or helper disable request. Preserve the original bootstrap as a
pass and classify the later event as a separate transport-durability failure.
Do not infer an always-on TLS lease from one successful connection; monitor the
listener and exact shell target across network transitions.

With ADB configuration established before arming, the separate automatic
guardian later restored the original station network without operator recovery.
Saved-network inventory remained exact and the `adbd` PID was unchanged. This
qualifies the guardian's automatic restoration under a stable daemon; it does
not show that the guardian survives a later ADB transport or daemon
reconfiguration.

Creating a WPA2 configuration can yield Android-normalized WPA2/WPA3 security
parameters. Establish ownership using an absent temporary SSID and the newly
returned network ID, then read and bind the stored nonsecret configuration.
Comparing the untouched request against the normalized profile can reject a
successful addition and leave cleanup work behind. Persist the returned ID
before further validation, retain USB recovery, and remove only the owned
temporary profile.

An elevated Windows provider's `CurrentUserOnly` named pipe rejected a caller
with the same user SID but a different token-owner SID. This matches the
[documented .NET owner-SID defect](https://github.com/dotnet/runtime/issues/123903).
A private run-directory control exchange subsequently passed live status
readback across elevation.

The first live file-control STOP was not observed. Its status publication froze
when the STOP file was created, and an exact production-loop reproduction
returned Windows sharing violation `0x80070020`. Preserve that failed attempt;
its original provider later reached TTL and cleaned up. The corrected controller
closes the temporary publication file before an atomic no-overwrite publish,
allows shared reads, bounds I/O retry, and supervises the control task. Its
17-check self-test, now exercising the production control loop, passed twice.

The corrected host-only retest completed 12 status calls and issued STOP about
160 seconds before TTL. The terminal receipt recorded `explicit_stop`; exact-
owner processes, listener, firewall rule, and control files were gone, while
the host's physical Wi-Fi SSID remained unchanged. This qualifies explicit host
STOP and owned host cleanup for the corrected file-control route. It does not
extend the separate Quest TLS durability result or prove that a detached Quest
guardian survives ADB daemon reconfiguration.

## AOSP expectations and references

- [Android SELinux](https://source.android.com/docs/security/features/selinux)
  documents default-deny mandatory access control for Android processes,
  including root processes.
- [Android 14 Shell manifest](https://android.googlesource.com/platform/frameworks/base/+/refs/tags/android-14.0.0_r60/packages/Shell/AndroidManifest.xml)
  lists Shell-package permissions. Manifest presence does not prove a specific
  service call or effect.
- [Android 14 Binder SELinux macros](https://android.googlesource.com/platform/system/sepolicy/+/refs/heads/android14-release/public/te_macros)
  show Binder transfer and FD-use policy as distinct permissions.
- [Android 14 native Parcel API](https://android.googlesource.com/platform/frameworks/native/+/refs/heads/android14-release/libs/binder/include/binder/Parcel.h)
  documents descriptor duplication and ownership.
- [Android 14 `ParcelFileDescriptor`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android14-release/core/java/android/os/ParcelFileDescriptor.java)
  supplies pipe and connected socketpair primitives.
- [Android 14 `SharedMemory`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android14-release/core/java/android/os/SharedMemory.java)
  documents protection, mapping, unmapping, and descriptor ownership.
- [Shizuku](https://github.com/RikkaApps/Shizuku) is implementation prior art
  for an ADB/root-started `app_process`, Binder delivery, caller authorization,
  and lifecycle handling. Its ADB backend is shell, not root, and its behavior
  does not establish Quest results.
- [QuestEscape companion research](https://github.com/QuestEscape/research)
  documents the legacy BLE method surface and protected-credential authentication
  shape; it is historical reverse engineering rather than a current supported
  bootstrap contract.
- [The Android 16 Pixel reproduction](https://github.com/thedjchi/Shizuku/issues/165)
  records the hosted-hotspot/UI timing race and its continued ADB pairing step;
  it is not Quest Android 14 evidence.
- [Termux's Android Tools package recipe](https://github.com/termux/termux-packages/blob/master/packages/android-tools/build.sh)
  identifies the packaged upstream Android Tools distribution.
- [The packaged Android Tools ADB build](https://github.com/nmeum/android-tools/blob/35.0.2/vendor/CMakeLists.adb.txt)
  retains pairing, TLS, RSA, BoringSSL, and protobuf support, while its
  [mDNS patch](https://github.com/nmeum/android-tools/blob/35.0.2/patches/adb/0017-adb_wifi-remove-mDNS.patch)
  removes ADB-host mDNS resolution and automatic post-pair discovery.
- [Android 14 ADB daemon restart handling](https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/android14-release/daemon/restart_service.cpp)
  distinguishes the runtime classic-TCP service property from persistent
  configuration.
- [Android 14 SELinux property rules](https://android.googlesource.com/platform/system/sepolicy/+/refs/heads/android14-qpr3-s6-release/private/property.te)
  provide the AOSP comparison for the target policy inspection.

Keep public evidence sanitized. Preserve exact raw receipts privately, including
build identity, helper and APK hashes, exception chains, AVC source/target
contexts and object class, deadlines, state readback, and cleanup outcomes.
