# APK Install, Permission, Launch, And Crash Watch

This playbook is for development APKs on a Quest headset with Developer Mode
and ADB authorization already active.

## Install

```powershell
adb -s <serial> install -r -d -g <path-to.apk>
```

Flags:

- `-r`: reinstall over existing package.
- `-d`: allow version-code downgrade for development builds.
- `-g`: grant declared runtime permissions that Android allows at install time.

If installation succeeds but the app does not appear in Unknown Sources, check
the manifest launcher activity and app label:

```powershell
adb -s <serial> shell dumpsys package <package> > <out-dir>\dumpsys-package.txt
adb -s <serial> shell cmd package resolve-activity --brief <package>
```

An APK can be installed without exposing a normal launcher entrypoint.

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
