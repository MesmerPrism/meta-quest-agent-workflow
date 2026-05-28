# OpenXR Tracking Boundary

Fused HMD and controller pose belongs to the active XR app's OpenXR session.
ADB, a shell helper, a broker, and a 2D Android service are useful around an XR
app, but they are not a supported public route to another process's fused
tracking stream.

## Correct Ownership

The foreground XR app should:

```text
create the OpenXR instance/session
select reference spaces
poll actions
locate views and action spaces at the selected XrTime
record validity/tracked flags
submit layers
publish any app-owned diagnostics
```

If another local process needs tracking snapshots, build a thin adapter in the
foreground XR app:

```text
OpenXR frame loop
  -> locate views/actions
  -> sanitize and timestamp sample
  -> publish over app-owned UDP/TCP/WebSocket/broker route
```

## What ADB Can Test

ADB can test Android-level routing:

```powershell
adb -s <serial> shell input keyevent KEYCODE_BACK
adb -s <serial> shell input tap <x> <y>
adb -s <serial> shell input text <text>
```

These are not proof of Meta Touch controller action bindings or OpenXR input.

## Readiness Signals

OpenXR render readiness usually needs app logs or app status markers. Useful
markers include:

```text
OpenXR session running
valid view pose
nonzero XR cadence
frame submitted
source/projection contract logged
visible projection ready
```

Focus alone is not enough. An app can be foregrounded and still fail to render
or receive valid XR poses.

