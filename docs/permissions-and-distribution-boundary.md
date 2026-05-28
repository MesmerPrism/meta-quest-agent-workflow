# Permissions And Distribution Boundary

Quest development often combines three very different authority models:

```text
installed APK
ADB host or shell helper
manual headset user approval
```

Keep them separate.

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

