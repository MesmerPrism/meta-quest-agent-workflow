# Boot Wireless ADB Qualification

Use this playbook when qualifying a device-owned Wireless Debugging request
after reboot. Keep transport recovery separate from immersive-app readiness
in [mutation confirmation](host-headset-mutation-confirmation.md). The
application owns its preference, helper, scheduling and receipt contract;
Android and Horizon OS own authorization and the actual ADB listener.
Read-only transport observation can proceed while the immersive wearer gate
is blocked. Apply XR readiness checks when the selected action resumes XR,
not as a prerequisite for inspecting boot/network state.

## Reference Implementations

Start from maintained Rusty Morphospace examples and the selected owner's
current release/source contract rather than reconstructing a shell workflow:

- [Rusty Kiosk user controls](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/USER_CONTROL.md)
  and [CLI](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/docs/CLI.md)
  own the fixed Wi-Fi ADB request, reversible restart preference, same-signer
  setup helper and structured status. The main app does not hold
  `WRITE_SECURE_SETTINGS`; provision only the separately installed helper.
- [Kiosk example usage](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/examples/README.md),
  [boot and wearer examples](https://github.com/MesmerPrism/Rusty-Kiosk/blob/main/examples/boot-and-wearer.md)
  and [standalone autoboot example](https://github.com/MesmerPrism/Rusty-Kiosk/tree/main/examples/quest-autoboot)
  demonstrate app-owned boot composition and protected wearer boundaries.
  An example is source guidance, not an installed feature or platform grant.
  The standalone app's boot launch is separate from the Kiosk setup helper's
  secure-settings authority; installing that example does not provision ADB.
- [File Manager inspected deployment](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/inspected-deployment.md)
  and [operator parity](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/main/docs/operator-cli-parity.md)
  own exact-target artifact inspection, installed-byte confirmation and their
  advertised Kiosk adapters. A missing typed operation is a bounded provider
  gap, not permission to broaden the adapter.
- [Rusty Quest](https://github.com/MesmerPrism/rusty-quest) owns Android/Quest
  platform packaging, lifecycle and effective-runtime evidence. For streaming,
  [Manifold](https://github.com/MesmerPrism/rusty-manifold) owns accepted command
  and session state; [Hostess](https://github.com/MesmerPrism/rusty-hostess) owns
  host observation and cleanup. Transport recovery does not close an old
  unknown or pending application operation.

Use the exact owner commit and artifact selected for the run. Public `main`
links locate maintained examples; they do not replace pinned runtime inputs.

## Distinct Claims

| Claim | Required evidence |
| --- | --- |
| Restart preference enabled | Current helper-owned preference readback |
| Boot receiver ran | Receipt bound to current boot identity and boot count |
| Deferred request admitted | Current boot, live opt-in/grant, connected Wi-Fi and bounded expiry checked before the fixed request |
| Settings request completed | Matching helper receipt and independent setting readback; this does not prove transport |
| Modern Wireless Debugging ready | Current dynamic TLS connect port, reachable listener and exact-device connection returning Android shell UID |
| Recovery automatic | The ready evidence appears after a new boot without host re-enable or another approval during the observation window |
| Immersive workflow ready | Separate wearer, display, Shell vsync and app-owned OpenXR checks |

Do not interpret a JobScheduler callback, `adb_wifi_enabled=1`, a discovered
NSD endpoint, or a protected approval Activity as an active listener. Keep
classic TCP ADB on port `5555` separate from modern dynamic-port TLS Wireless
Debugging. A host `tcpip` command after reboot invalidates the automatic
device-owned recovery claim for that attempt.
An empty TLS-port property alone also does not prove absence: qualify the
actual socket/endpoint and authenticated shell, since a tested Quest TLS route
could be live without that property populated.

## Boot And Network Admission

`BOOT_COMPLETED` may precede the infrastructure Wi-Fi association. A tested
Quest boot request was rejected with "Not connected to any wireless network"
before Wi-Fi later acquired an IP; no later enable followed automatically.
Immediate boot dispatch alone therefore does not establish durable recovery.

A narrow implementation can defer one attempt until its assigned Wi-Fi
network is connected and has an address. Keep it non-persisted, time-bounded
and cancellable. Recheck boot identity, elapsed-time expiry, opt-in, grant and
network at dispatch, including deadline callbacks. Consume the attempt
durably before the Settings effect so process death cannot replay it. Opt-out
or explicit Wi-Fi ADB disable cancels a pending attempt. Network observation
permission does not require opening an Internet connection or a foreground
service, and it must not become polling or indefinite retry authority.

This addresses request timing; it cannot create network trust or guarantee
that a firmware preserves previously approved trust.

## Protected Approval And Trust

Host authorization and network authorization are separate. "Always allow
from this computer" concerns a host key; "Always allow on this network"
concerns the Wi-Fi BSSID. On a tested Horizon OS build, the installed approval
Activity had a genuine always-allow network route. Do not infer that the
checkbox is host-only merely because trust later disappears.

A same-signer helper's `WRITE_SECURE_SETTINGS` grant permits its fixed settings
request. It does not grant `MANAGE_DEBUGGING`, allow it to approve Meta's
protected prompt or permit ordinary app code to edit system-owned ADB trust.
Never automate that approval or manufacture a trusted network record.

For a failure, distinguish these independently:

1. Wi-Fi association and actual current BSSID;
2. helper opt-in, provisioning, boot delivery and request receipt;
3. current setting, listener and exact-device shell connection;
4. saved network trust before reboot and whether it survives afterward;
5. protected approval recurrence and system parse/error logs.

Retain trust evidence privately. Public reports should give entry counts and
whether the BSSID matched, without host keys, BSSIDs, IPs or device serials.
Use the already authorized diagnostic route; preserve the shared ADB daemon
and keys. Read-only trust inspection is diagnostic evidence, not permission
to edit the keystore.

## Measured Firmware Result And Causal Limit

An attended Quest 3S qualification on 2026-10-05 (Android 14, SDK 34,
Android build `UP1A.231005.007.A1`, OEM build `3697600032300610`) observed a reachable modern
TLS listener and Android shell UID after protected approval. Before reboot,
one saved network entry matched the current BSSID. After reboot on the same
BSSID, that entry was absent, host-key entries remained, Wireless Debugging
was off and no listener existed. No host re-enable occurred in that window.
This measures trust loss across that firmware's boot; it does not establish
that all Quest builds lose trust or that a later application update repairs it.
The OEM build identifier is not an independently verified Horizon marketing
version.

Read-only inspection of that installed system's ADB keystore loader found
`next()` followed by unconditional `skipCurrentTag`, including whitespace
events with a null element name. The retained boot log contained the matching
null-tag warning. Root-level whitespace can consequently skip all children;
separate host-key import can repopulate hosts and rewrite a store without
network entries. The dump read file text directly; standard Android dump
formatting preserves internal newlines. This is a strongly supported parser
explanation, not a fully instrumented OEM execution trace; installed XML/dump
utility bytes were not independently verified against AOSP. The inspected key
expiry code did not expire networks; an allowance of zero bypassed host-key
expiry rather than deleting network trust.

Retest the selected signed application/helper pair after any firmware or
implementation change. Record its exact source/artifact/channel and current
boot separately from the result above. A host test, successful release, saved
preference or repaired scheduler never promotes a pending physical test.

A later same-day test updated the existing Kiosk Labs pair through its signed
release route to `v0.6.6-alpha.10`, preserving stable installation and data.
The release used [Kiosk source `1b95f909`](https://github.com/MesmerPrism/Rusty-Kiosk/commit/1b95f909a399eb68dbeadea13111c7ca983298c6)
from [PR #36](https://github.com/MesmerPrism/Rusty-Kiosk/pull/36).
After a new boot, the Labs deferred boot job ran and Meta's protected Wireless
Debugging approval Activity became top-resumed after physical wake, without a
host re-enable or manual post-boot request. Saved network trust changed from
one matching entry to zero on the independently verified same BSSID; two
host-key entries remained.
Wireless Debugging was off and no network listener was discovered. The wearer
left the prompt unanswered during this automatic-recovery observation.
Unattended transport recovery failed in that window; deferred request timing
and protected approval recurrence are distinct results.

Two typed status queries timed out while that prompt was pending, despite
healthy USB/shell observation. After the wearer cancelled the prompt and
enabled MQDH Wi-Fi ADB, typed status worked and returned the durable helper
receipt for boot count 56: boot observation at elapsed `17868` ms, dispatch at
`19108` ms, outcome `requested`, connected Wi-Fi true, and both ADB settings
true at dispatch. Its message still required Meta approval. This physically
qualifies the bounded boot/network-ready request timing; the receipt does not
prove a listener. The earlier independent setting/listener observations and
sealed automatic-failure window remain valid. Both cancellation and host
enable changed before status succeeded, so neither alone is proven to explain
the earlier timeouts.

### Subsequent MQDH Classic TCP Result

The wearer declined the modern approval, cancelled that prompt and manually
used Meta Quest Developer Hub's Wi-Fi ADB toggle for the same exact headset.
Readback then showed `service.adb.tcp.port=5555`, empty
`persist.adb.tcp.port`, modern `adb_wifi_enabled=0` and no saved network-trust
entry. A current `_adb._tcp` advertisement and listener on `5555` appeared;
the authenticated network shell matched canonical device identity, current
boot count 56 and `uid=2000(shell)`. The wearer reported no new network
approval prompt for this MQDH action.

This proves the host-mediated classic TCP route worked on that boot. It does
not restore modern TLS network trust, prove operation without the attached
USB cable, or establish classic TCP persistence across another reboot. The
host toggle occurred after the sealed automatic observation and cannot count
as automatic boot recovery. In future trials classify the actual setting,
port, advertisement and shell identity rather than using "Wi-Fi ADB" as if
it named one authorization mechanism. Android documents both the modern
Wireless Debugging route and USB-initiated `adb tcpip` networking in
[its ADB Wi-Fi instructions](https://developer.android.com/tools/adb#connect-to-a-device-over-wi-fi).

### Later Attended Boot Approval Result

A separate attended trial on 2026-10-05 retained the same signed Labs
`v0.6.6-alpha.10` pair and verified modern TLS before one real reboot. On new
boot count 57, the device-owned deferred job observed boot at elapsed `17518`
ms and dispatched at `18545` ms with connected Wi-Fi and outcome `requested`.
Meta's protected network approval prompt appeared without a second Kiosk
request, host enable, pairing or host `adb tcpip` action after reboot.

Before approval, saved network trust had again changed from one matching entry
to zero on the independently verified same BSSID; two host-key entries remained.
Wireless Debugging was off, no selected-headset TLS endpoint was discovered,
and the classic TCP property was empty. A socket diagnostic reported a
permission error, so its output does not prove universal socket absence.
The wearer accepted the existing boot-generated prompt with **Always allow on
this network**. Discovery and connection then reached a dynamic modern TLS
endpoint whose authenticated shell matched canonical headset identity, the
new boot and `uid=2000(shell)`. Readback showed Wireless Debugging enabled,
one matching saved network entry, two unchanged host-key entries and no
protected prompt. The classic TCP property remained empty.

This verifies real reboot, Wi-Fi-ready boot request, attended approval and
modern network shell in one sequence. It closes the previously untested
post-boot approval stage without changing boot 56's cancelled trial or its
failed unattended window. The USB cable remained attached. USB-free startup,
prompt-free recovery, corrected firmware and XR readiness remain unqualified;
the reproduced same-network trust loss and qualified parser hypothesis remain
separate findings.

### Can An Autobooter Reproduce The Classic Host Toggle?

The inspected MQDH 6.5.2 handler sends `adb tcpip` through the selected host
ADB transport and then connects. Android handles that protocol request inside
adbd, whose [restart service](https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/android14-release/daemon/restart_service.cpp)
writes `service.adb.tcp.port`. The ordinary helper's
`WRITE_SECURE_SETTINGS` grant neither supplies adbd's process/SELinux identity
nor grants `MANAGE_DEBUGGING`. The inspected helper setting path requests
modern TLS; no supported fixed classic switch under its existing grant was
verified. An OEM-entitled route remains a separate possibility to verify,
not a capability inherited from boot delivery or a previous connection.

Creating a hotspot, discovering a service or running an ADB client does not
create a missing listener. The maintained
[Termux Lab recovery helper](https://github.com/MesmerPrism/quest-termux-lab/tree/3701e821bfe8e7b7e4759904cf5b77d079df1075/examples/wireless-adb-recovery-helper)
reads state and connects to an existing TLS endpoint; it does not fall back
to `5555`. Its [published results](https://github.com/MesmerPrism/quest-termux-lab/blob/3701e821bfe8e7b7e4759904cf5b77d079df1075/docs/QUEST_RESULTS_PUBLIC.md)
separate working local topology from negative TLS startup. Two tested
Android 14 AP-free timing orderings did not establish an authorized shell;
this does not rule out every firmware or future entitled mechanism.

Likewise, the [shell/BLE handoff](offline-hotspot-shell-ble-handoff.md) retains
a UID-2000 process launched through already authorized ADB, with bounded
lifetime. Surviving link loss is not surviving OS reboot or creating fresh
shell authority. The current [Rusty Quest shell-capability examples](https://github.com/MesmerPrism/rusty-quest/tree/5f0800b3987e46adc43196ba884d71c12d5178af/tools/diagnostics/quest-shell-capabilities)
retain that bootstrap/lifetime boundary. Use those owner examples for the behavior they prove. A
new cold-boot experiment needs a concrete supported actor that starts the
listener without relying on the listener it is meant to create; no such route
was verified in these audits. Do not count another client or topology trial
as evidence that this startup dependency has been resolved.

Primary boundaries:

- [Android Wireless Debugging](https://developer.android.com/tools/adb#connect-to-a-device-over-wi-fi)
- [ADB authorization and keystore implementation](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/services/core/java/com/android/server/adb/AdbDebuggingManager.java)
- [Protected Wireless Debugging service API](https://android.googlesource.com/platform/frameworks/base/+/3c8f521638127b866ff43a277129c14ed307e3ff/services/core/java/com/android/server/adb/AdbService.java)
- [Android 14 XML skip semantics](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-14.0.0_r1/core/java/com/android/internal/util/XmlUtils.java)

## Stable And Labs Updates

Choose the intended channel before staging artifacts. Kiosk stable and Labs
are separately installed product identities, each with its own main/helper
pair, control permission, job namespace and private preference state. Inspect
the selected release manifest, package/version and signer continuity; grant
only that channel's helper and confirm its matching control path. Updating
Labs must not overwrite stable or infer stable provisioning from Labs state.

Use the owner's existing signed release pipeline and new versioned assets.
For deployment of already published exact assets, inspect those artifacts and
their release provenance; an additional local rebuild is not required.
If the signer differs, stop that update path; debug replacement, uninstall or
data clear is not a substitute for a signed channel upgrade. Keep unrelated
installed apps and accepted historical receipts intact.
When that channel is proven absent, use its ordinary clean-install route;
do not compare the separately installed stable package's signer as if it were
a prior Labs version. Session authorization for the selected update and
bounded recovery persists; do not add another permission gate for the same
already authorized action.
