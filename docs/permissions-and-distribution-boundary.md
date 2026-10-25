# Permissions And Distribution Boundary

Quest development often combines three very different authority models:

```text
installed APK
ADB host or shell helper
manual headset user approval
```

Keep them separate.

## Managed Device And Store Authority

Managed-device enrollment does not give an ordinary launcher the device
owner's authority. First identify the Horizon managed mode:

- Individual Mode can expose the consumer Store when administrator policy
  permits it, including account-scoped paid purchases.
- Shared Mode does not expose the consumer Store; its managed **Discover
  Apps** catalog is a separate administrator distribution surface.

Opening a Store Activity through ADB is developer lifecycle control, not
purchase consent. Buying, entering a Store PIN, adding payment, accepting
terms, and choosing an account remain attended wearer actions. Managed and
personal account libraries are separate, so validate under the same
user/profile as the launcher. See
[Managed Device Store Apps And Paid Entitlements](managed-device-store-apps.md).

## Installed APK

An installed APK can only use permissions that are declared in its manifest and
granted by Android/Horizon OS policy.

Common development permissions:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="horizonos.permission.HEADSET_CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="org.khronos.openxr.permission.OPENXR" />
<uses-permission android:name="org.khronos.openxr.permission.OPENXR_SYSTEM" />
```

Scene, anchor, hand-tracking, Bluetooth, network, and MediaProjection related
permissions are app-specific. Add only what the app actually uses.

## Fresh UID And Selected-Feature Preflight

A new package UID has its own effective permission state. A prior package's
grant, a manifest declaration, key enrollment, successful install or SDK
operation does not prove that this UID can use its selected camera/depth
features. An update retaining the same UID is not a fresh-UID observation;
bind the actual installed package and UID rather than assuming either state.

Derive required permissions from the authenticated selected APK/profile and
its owning platform contract, not every declaration in the manifest:

| Selected dependency | Permission observation |
| --- | --- |
| Passthrough camera access requiring both grants | `android.permission.CAMERA` and `horizonos.permission.HEADSET_CAMERA` |
| Environment depth | The declared scene/depth permission, currently `horizonos.permission.USE_SCENE` on applicable Horizon profiles |
| Identity/key inspection only | Do not activate camera or depth merely to inspect identity |

For a camera-plus-environment-depth profile, all three required grants must
be established. Do not add depth permissions to a profile that does not select
depth. Older SDK documentation may use `com.oculus.permission.USE_SCENE`;
observe the actual manifest/platform name, not both names as interchangeable
grants. Meta's [Depth API troubleshooting](https://developers.meta.com/vr/documentation/unity/unity-depthapi-troubleshooting-faq/)
requires `USE_SCENE` before depth access. OpenXR permits
[`XR_ERROR_NOT_PERMITTED_PASSTHROUGH_FB` from depth-provider creation](https://registry.khronos.org/OpenXR/specs/1.1/man/html/xrCreateEnvironmentDepthProviderMETA.html)
when app permissions are missing; unsupported-feature and resource-limit
failures are different reasons.

Prefer the selected File Manager's typed observation:

```text
<qfm> apk permissions --serial <serial> --package <package> --json --adb <selected-adb>
```

Retain the real exit and complete stdout/stderr. For
`questionable.file_manager.apk_permission_observation.v1`, require
`succeeded: true`, exact `result.Serial` and `result.PackageName`, each required
`ManifestDeclaredPermissions[].Name`, and exactly one matching
`EffectiveGrants[]` row whose `Granted` is Boolean true. Missing, duplicate,
unavailable or false grant rows do not establish the dependency. AppOps are
separate observations, not aliases for effective grants. Preserve source/APK,
UID, actor/birth, boot, helper, current-care and actual expiry checks.

Observation does not grant permissions. If the chosen typed provider has no
grant operation, an already-authorized developer operation may use the bounded
[ADB grant fallback](#adb-grants) for one required, declared, actually denied
permission. Record the provider gap, exact target/dependency, mutation intent,
stop condition and retained-state policy; this playbook grants no authority.
Stop on refusal, preserve platform/wearer approval, and repeat typed effective
readback before confirming. Do not grant the whole manifest, reset app data,
restart actors, reset the media session or retry automatically. Existing
operation authorization persists; no extra per-permission approval ceremony
is implied. Public app UX still owns its normal permission request.

A successful depth-provider handoff proves that boundary only. Camera delivery,
Native image adoption, moving pixels, cadence, cleanup and freshness acceptance
remain separate owner evidence. Increasing log capacity cannot repair a denied
feature. See [signal patterns](quest-signal-patterns.md#finite-observer-readiness-and-window).

## ADB Grants

For development runs:

```powershell
adb -s <serial> shell pm grant <package> android.permission.CAMERA
adb -s <serial> shell pm grant <package> horizonos.permission.HEADSET_CAMERA
adb -s <serial> shell pm grant <package> android.permission.POST_NOTIFICATIONS
```

Check readback:

```powershell
adb -s <serial> shell dumpsys package <package>
```

If `pm grant` reports that a permission is unknown, not changeable, or not
requested, fix the manifest or use the headset UI path. Do not treat a failed
grant as harmless for unattended tests.

## AppOps

Some flows use app operations as well as runtime permissions. Example:

```powershell
adb -s <serial> shell appops set <package> PROJECT_MEDIA allow
adb -s <serial> shell appops get <package> PROJECT_MEDIA
```

MediaProjection can still require user consent even when an app-op is set.

## Shell Helper

An ADB-launched helper can run with shell-level privileges. That does not mean
the installed APK has those privileges. Document helper actions as developer
tooling, not app behavior.

Examples of shell-helper responsibilities:

```text
package inspection
launch and focus readback
bounded screenrecord or screenshot
proximity/watchdog support
dumpsys snapshots
logcat streaming
broker status forwarding
```

## Public Distribution

For public sharing, make the APK launch without assuming:

```text
local ADB host
private broker
private package names
shell helper
developer settings already changed
pre-granted permissions not declared in the manifest
```

If a workflow requires ADB, label it as a developer workflow. If it requires a
sidecar service or broker, name that dependency explicitly.

## App Updates

Normal installed apps should not be described as silently self-updating on
unmanaged Quest devices. An app can download and verify an APK and hand it to
Android's installer, but the user should expect installer trust and
confirmation gates unless the installer has device/profile-owner authority or
another supported management channel.

Termux plus loopback WiFi ADB is different: if Termux is using an active,
user-authorized ADB shell lease and `adb shell id` reports `uid=2000(shell)`,
then `adb install -r` is a developer/fleet-operations action that can update a
verified APK without the normal app installer UI. Keep that authority boundary
explicit and do not describe it as Termux or the APK having silent install
privileges.

A normal helper APK can be part of that lab recovery lane only when its scope
is narrow and visible. A live Quest probe showed that a launched, pre-granted
helper Activity can call Termux's `RunCommandService` with
`startForegroundService()` and restart one fixed fleet-agent command after
Termux was stopped. The proof condition is a fresh fleet-agent heartbeat plus
the same loopback ADB `uid=2000(shell)` gate before any install. This is not
WiFi ADB setup, reboot-durable management, arbitrary shell authority, or an app
permission that allows silent update.
