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

## Parallel Devices And Clients

One default ADB server is designed to multiplex multiple connected devices and
multiple client processes. Keep that daemon shared and run independent work in
separate terminals with an explicit serial on every device command:

```powershell
adb -s <serial-a> shell getprop ro.product.model
adb -s <serial-b> shell getprop ro.product.model
```

Coordinate exclusive work per device rather than locking the daemon merely
because a command uses ADB. Reserve or lock the ADB server lifecycle only before
global operations such as `adb kill-server`, daemon start/restart or recovery,
Wi-Fi ADB setup, changing ADB binaries or authorization keys, or intentionally
owning another server port. A broad `adb-server` lock should not block normal
`adb devices` discovery or serial-scoped commands.

Running a second ADB server on another port is possible, but two host daemons
can compete for the same USB interfaces. Use a separate server port only when
it owns a deliberately isolated transport; use a VM or another host when USB
ownership must be truly separate.

USB and Wi-Fi selectors can refer to the same headset. Bind the chosen selector
to its actual canonical serial and boot identity before effects, and retain
that transport in the run inputs. Moving administration to USB can preserve the
media network, but it does not silently migrate an already reviewed Wi-Fi run.

For an authorized awake watchdog, preserve the user's polling cadence and end
condition. Supervise only the task-owned worker, identified by executable,
arguments and birth observation; refresh a bounded hold before it expires.
During topology changes, pause that worker without releasing its device hold,
then resume after the intended transport/network is observed and a healthy
heartbeat arrives. Awake/display readback does not prove camera or XR readiness.

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

## Retain Mutable State Before Reset

A `files`/`shared_prefs` archive covers only those directories. Resolve the
selected application's storage contract before a data clear, uninstall, or
identity reset: identity, enrollment and replay/cleanup journals may live in
`no_backup`, databases or other owner-declared storage. Android's
[`getNoBackupFilesDir()`](https://developer.android.com/reference/android/content/Context#getNoBackupFilesDir())
excludes its files from automatic remote backup; that is not evidence that the
files are disposable or that an ordinary backup retained them.

Use the application's typed export/archive operation when available. A
serial-scoped `run-as` fallback is limited to an accessible debuggable package;
retain the owner-selected mutable paths, directory inventory, archive size and
digest, command exit/status and stderr privately. Record absent or inaccessible
paths explicitly. Verify the required identity/journal entries in the archive
before describing the declared coverage as retained. Follow
[Artifact And Evidence Discipline](artifact-and-evidence-discipline.md#mutable-app-state).

Exclude immutable media only when its exact content identity and independent
retention/reconstruction route are already bound. Do not recopy it for every
mutable-state snapshot. A live file copy is not an atomic or restorable snapshot:
use the owner's consistency procedure where supported, otherwise state that
limitation. Do not force-stop or reset merely to improve archive consistency.

Use existing authorization, including explicit standing delegation, for the
selected archive/reset operation; ask only for missing scope. Archiving grants
no reset, replay or restore authority. Restoring old identity or replay data
requires the owner's compatibility and identity rules; a retained journal does
not prove its recorded cleanup is terminal.

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
