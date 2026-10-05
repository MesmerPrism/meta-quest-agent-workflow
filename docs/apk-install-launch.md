# APK Install, Permission, Launch, And Crash Watch

For repeatable agent work, first discover the typed capabilities of
QuestIonAble File Manager. Prefer its inspected-artifact install and resolved
launcher route when available: those routes bind the artifact digest and
identity to one exact target and require fresh installed-state readback.

Use the direct ADB procedure below as an explicitly labeled fallback for a
missing provider capability, provider troubleshooting, or novel diagnostics.
Do not relabel fallback output as File Manager, Fleet, Manifold, or
application-owned evidence. See
[Agent Execution Providers](agent-execution-providers.md).

For the complete build -> File Manager -> Kiosk -> app-evidence sequence, use
[Rusty Morphospace Default Device Loop](rusty-morphospace-default-device-loop.md).
The ADB commands in this document are not the default routine Morphospace
deployment path.

This playbook is for development APKs on a Quest headset with Developer Mode
and ADB authorization already active.

## Install

```powershell
adb -s <serial> install -r <path-to.apk>
```

Flags:

- `-r`: reinstall over existing package.
- Add `-d` only for an explicitly selected development downgrade.
- Add `-g` only when the selected profile requires its declared runtime grants;
  otherwise grant only the required permissions separately.

For a preserved update, inspect package identity, channel, version code and
signer continuity before dispatch. Prefer the owner's existing signed release
pipeline and exact assets. Do not replace a release with a debug signer,
uninstall or clear data to work around a signature mismatch. Separately
installed stable and Labs main/helper pairs need channel-specific inspection
and provisioning. See [boot and helper qualification](boot-wireless-adb-qualification.md).

If installation succeeds but the app does not appear in Unknown Sources, check
the manifest launcher activity and app label:

```powershell
adb -s <serial> shell dumpsys package <package> > <out-dir>\dumpsys-package.txt
adb -s <serial> shell cmd package resolve-activity --brief <package>
```

An APK can be installed without exposing a normal launcher entrypoint.
This is expected for a setup helper. Confirm its declared fixed receiver or
service and owning app's control/status route rather than rejecting the
artifact or inventing a launcher.

## Permission Grants

Grant only permissions declared by the APK and required by the profile:

```powershell
adb -s <serial> shell pm grant <package> android.permission.CAMERA
adb -s <serial> shell pm grant <package> horizonos.permission.HEADSET_CAMERA
adb -s <serial> shell pm grant <package> android.permission.POST_NOTIFICATIONS
adb -s <serial> shell pm grant <package> android.permission.RECORD_AUDIO
```

Some permissions are install-time, signature, special, or not changeable with
`pm grant`. If ADB says a permission is not changeable, preserve that output.
The fix may be manifest declaration, headset UI, or removing a feature
assumption.

For Quest scene or spatial APIs, inspect logs for the exact missing permission
string before guessing. Add only the permissions required by the API actually
used by the app.

## Launch

Direct component launch:

```powershell
adb -s <serial> shell am start -n <package>/<activity>
```

Launch via monkey when you only know the package:

```powershell
adb -s <serial> shell monkey -p <package> -c android.intent.category.LAUNCHER 1
```

Force-stop before launch when testing cold-start behavior:

```powershell
adb -s <serial> shell am force-stop <package>
adb -s <serial> shell am start -n <package>/<activity>
```

Treat `force-stop` as an app lifecycle operation. It may change immersive
state, background services, and any broker or companion surfaces.

## Data Reset Boundary

Before an authorized data clear, uninstall or identity reset, retain the
owner-declared mutable state using [the archive procedure](adb-basics.md#retain-mutable-state-before-reset).
Cold-process force-stop, data reset and reinstall are distinct operations.
Retain unresolved owner receipts; reset completion does not prove camera,
renderer, GPU or session cleanup. Use the selected owner's reset route and
fresh effective-state readback within the existing authorization.

## Tasks, Processes, And Launcher Handoffs

Leaving an app normally stops its Activity and backgrounds its task. Android
may retain that process as a cache and reclaim it later. This is not an
accumulating foreground CPU/GPU workload for a well-behaved app, although
app-owned services, audio, downloads, or faulty workers can continue.

Task flags do not provide process authority:

- `FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_CLEAR_TASK` can provide a fresh
  Activity/task for an initial kiosk launch;
- Android may still reuse the same Linux process and process-wide state;
- `FLAG_ACTIVITY_REORDER_TO_FRONT` can resume the existing task when a soft
  watchdog recovers it;
- an ordinary launcher cannot finish another package's task or reliably kill
  arbitrary Store apps.

Do not add privileged force-stop behavior merely to clean cached tasks. Use
`am force-stop <package>` only for an explicitly authorized cold-process test,
and stop only the named target. See
[Managed Device Store Apps And Paid Entitlements](managed-device-store-apps.md).

## Crash Watch

Use a bounded run directory:

```powershell
$out = ".\artifacts\launch-smoke"
New-Item -ItemType Directory -Force $out | Out-Null
adb -s <serial> logcat -c
adb -s <serial> shell am start -n <package>/<activity>
Start-Sleep -Seconds 10
adb -s <serial> logcat -d -v threadtime > "$out\logcat.txt"
adb -s <serial> shell pidof <package> > "$out\pid.txt"
adb -s <serial> shell dumpsys window > "$out\dumpsys-window.txt"
```

Look for:

- `FATAL EXCEPTION`
- `AndroidRuntime`
- `UnsatisfiedLinkError`
- `Unable to find native library`
- missing uses-permission strings
- OpenXR loader or extension errors
- lifecycle loops such as resume/pause/focus/window init/window terminate
- render-loop evidence, frame counters, or explicit fallback clear logs

## Native Library Name Mismatch

If logs contain:

```text
java.lang.IllegalArgumentException: Unable to find native library main
```

then Android was asked to load `libmain.so` but the APK packaged a differently
named `.so`. Fix one of these:

- manifest metadata or activity configuration that names the native library;
- packaging that duplicates or renames the native library to the expected
  `lib<name>.so`;
- app code that calls `System.loadLibrary`.

Verify APK contents:

```powershell
jar tf <path-to.apk> | findstr /i "\.so AndroidManifest"
```

## OpenXR Lifecycle

An immersive OpenXR activity should wait until Android is resumed, focused, and
has a native window before creating or beginning the OpenXR session. If the
native window terminates, the app must be able to recreate renderer state.

Useful evidence:

- Android lifecycle logs: resumed, paused, focused, lost focus, window
  initialized, window terminated.
- OpenXR session states: `READY`, `SYNCHRONIZED`, `VISIBLE`, `FOCUSED`.
- Frame counter logs after `xrBeginFrame` / `xrEndFrame`.
- A visible fallback clear or test pattern before camera frames arrive.

If the view is black, separate renderer liveness from camera liveness. A bright
fallback clear proves the render loop is alive before camera acquisition is
debugged.
