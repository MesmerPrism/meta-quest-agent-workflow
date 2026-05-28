# Troubleshooting

## App Not Visible In Unknown Sources

Check package and launcher activity:

```powershell
adb -s <serial> shell pm list packages | findstr /i "<package-fragment>"
adb -s <serial> shell cmd package resolve-activity --brief <package>
adb -s <serial> shell dumpsys package <package>
```

An app may install successfully but not appear if it has no appropriate
launcher/VR category, uses a different label than expected, or the install went
to another connected device.

## Native Library Not Found

Crash symptom:

```text
java.lang.IllegalArgumentException: Unable to find native library main
```

Check the APK:

```powershell
jar tf <apk> | findstr /i "lib/arm64-v8a"
```

The manifest/native activity `android.app.lib_name` must match the bundled
library name without the `lib` prefix and `.so` suffix.

## Black View After Launch

Collect:

```powershell
adb -s <serial> logcat -c
adb -s <serial> shell am start -n <package>/<activity>
Start-Sleep -Seconds 10
adb -s <serial> logcat -d -v threadtime > <out-dir>\logcat.txt
adb -s <serial> exec-out screencap -p > <out-dir>\screenshot.png
```

Look for:

```text
activity resumed/focused, then paused/lost focus
native window initialized, then terminated
OpenXR session exiting
invalid view pose loops
camera permission missing
texture import/decode failures
no frame-submit marker
```

A black screenshot can mean app lifecycle failure, protected compositor
content, camera source failure, or capture-route limitation. Pair screenshots
with logs and app status.

## Missing Permission

If logs mention a missing `uses-permission`, add it to the manifest. A runtime
grant cannot fix a permission that the APK did not request.

Check:

```powershell
adb -s <serial> shell dumpsys package <package> | findstr /i "permission grant"
```

## Camera Frames Missing

Check both permission and source state:

```powershell
adb -s <serial> shell pm grant <package> android.permission.CAMERA
adb -s <serial> shell pm grant <package> horizonos.permission.HEADSET_CAMERA
adb -s <serial> shell dumpsys media.camera
```

Then inspect app logs for stream open, first frame timestamp, source size, and
projection/source mapping metadata.

## Screenshot Too Early

Use a readiness gate before capturing:

```text
start logcat window
launch app
wait for source/projection/OpenXR readiness marker
settle for a short fixed interval
capture screenshot
capture logcat window
```

Do not treat a launcher foreground event as visual readiness.

## Stale Or Frozen Visual Evidence

Capture multiple frames and compare hashes:

```powershell
adb -s <serial> exec-out screencap -p > frame-00.png
Start-Sleep -Milliseconds 1000
adb -s <serial> exec-out screencap -p > frame-01.png
```

If hashes are identical for live camera content, inspect app frame counters and
camera timestamps before accepting the run.

## MediaProjection Prompt Or Select View Panel

MediaProjection may require headset approval and can show a protected prompt or
view selector. Record the prompt as part of the test. ADB cannot turn that into
a normal app permission.

## hzdb Unavailable

Fallback to ADB:

```powershell
adb devices -l
adb -s <serial> logcat -d -v threadtime
adb -s <serial> exec-out screencap -p
adb -s <serial> shell dumpsys package <package>
```

Record that `hzdb` was unavailable and which ADB substitute was used.

