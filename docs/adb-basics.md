# ADB Basics For Quest Agents

ADB is a developer bridge. It can install apps, launch activities, collect
logs, pull files, forward ports, and run diagnostic shell commands after the
user has enabled Developer Mode and authorized the host.

ADB is not a way to bypass headset permissions, enable Developer Mode from a
locked retail device, read protected compositor internals, or sample another
app's fused OpenXR tracking stream.

## Device Discovery

Use a serial whenever more than one Android device might be present:

```powershell
adb devices -l
adb -s <serial> shell getprop ro.product.model
adb -s <serial> shell getprop ro.product.device
adb -s <serial> shell getprop ro.build.version.release
adb -s <serial> shell getprop ro.build.version.sdk
adb -s <serial> shell getprop ro.build.fingerprint
```

Display basics:

```powershell
adb -s <serial> shell wm size
adb -s <serial> shell wm density
adb -s <serial> shell dumpsys display
```

Power and battery readback:

```powershell
adb -s <serial> shell dumpsys battery
adb -s <serial> shell dumpsys power
```

Treat power and proximity commands that change state as device-setting
operations. Do not run them as part of normal inspection unless the current
test explicitly needs them.

## Foreground And Focus

For most launch checks, focused window evidence is enough:

```powershell
adb -s <serial> shell dumpsys window | findstr /i "mCurrentFocus mFocusedApp"
```

Use broader activity dumps only when needed:

```powershell
adb -s <serial> shell dumpsys activity top
```

Repeated heavy `dumpsys activity activities` calls can be noisy and slow on a
headset. Prefer focused checks in tight validation loops.

## Logs

Clear before a controlled run:

```powershell
adb -s <serial> logcat -c
```

Dump after launch:

```powershell
adb -s <serial> logcat -d -v threadtime > <out-dir>\logcat.txt
```

Focused tag capture:

```powershell
adb -s <serial> logcat -d -v threadtime -s <tag1> <tag2> > <out-dir>\logcat-focused.txt
```

When a process crashes immediately, capture full logcat first, then filter. The
unfiltered file often contains Android package-loader, permission, linker, and
OpenXR loader lines that app tags do not show.

## Screenshots

Simple screenshot:

```powershell
adb -s <serial> exec-out screencap -p > <out-dir>\screenshot.png
```

This is a final display witness, not raw camera access. Record it separately
from MediaProjection, casting, screenrecord, and app-private camera frames.

## Files

Pull a public device file:

```powershell
adb -s <serial> pull <device-path> <local-dir>
```

Pull app-private files from a debuggable app:

```powershell
adb -s <serial> shell run-as <package> ls files
adb -s <serial> exec-out run-as <package> cat files/<name>.json > <out-dir>\<name>.json
```

`run-as` works only for debuggable apps whose package data is accessible to
that user. Failure is normal for release builds.

## Port Forwarding

Host to Quest service:

```powershell
adb -s <serial> forward tcp:<host-port> tcp:<device-port>
curl.exe http://127.0.0.1:<host-port>/status
```

Quest app to host service:

```powershell
adb -s <serial> reverse tcp:<device-port> tcp:<host-port>
```

Record forwards in run evidence and remove them when no longer needed:

```powershell
adb -s <serial> forward --remove tcp:<host-port>
adb -s <serial> reverse --remove tcp:<device-port>
```

## Synthetic Input Boundary

ADB input can prove Android input routing and app focus. It does not emulate
Meta Touch/OpenXR controller actions completely.

```powershell
adb -s <serial> shell input keyboard keyevent KEYCODE_O
adb -s <serial> shell input keyevent KEYCODE_BUTTON_A
adb -s <serial> shell input gamepad keyevent KEYCODE_BUTTON_A
adb -s <serial> shell input joystick keyevent KEYCODE_BUTTON_A
```

If a keyboard fallback fires, the app is focused enough to receive that Android
input. If an OpenXR action does not fire from synthetic ADB input, use a real
controller test before concluding the controller path is broken.
