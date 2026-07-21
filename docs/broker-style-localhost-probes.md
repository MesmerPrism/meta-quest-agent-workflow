# Manifold And App-Owned Localhost Probes

The filename is retained for compatibility with existing links. For current
Rusty Morphospace work, Manifold owns accepted command, session, stream, and
control-transport state. A Quest app or sidecar endpoint is an adapter or
diagnostic surface; it is not a parallel broker authority. See
[Rusty Morphospace Repo Routing](rusty-morphospace-repo-routing.md).

Quest apps and sidecar services are easier to validate when they expose a
small local diagnostic surface. This pattern is useful for agents because it
turns "is the headset doing the right thing?" into a set of explicit readbacks
instead of only screenshots and logcat.

## Shape

Common endpoints:

```text
GET  http://127.0.0.1:<port>/status
GET  http://127.0.0.1:<port>/clock/now
GET  http://127.0.0.1:<port>/clock/health
WS   ws://127.0.0.1:<port>/<events-path>
POST http://127.0.0.1:<port>/<command-path>
```

Use ADB forwarding from the host:

```powershell
adb -s <serial> forward tcp:<host-port> tcp:<device-port>
curl.exe http://127.0.0.1:<host-port>/status
```

The status object should be small, stable, and safe to record in logs. Prefer
field names that separate:

```text
app lifecycle
foreground/focus state
clock/timebase state
stream state
camera permission state
source metadata
decoder/import/render state
watchdog/helper state
last command acknowledgement
```

## Control-Service Readiness Is Not Render Readiness

A local status endpoint can prove that a sidecar service is alive. It cannot by
itself prove that a foreground XR app has:

```text
created an OpenXR session
received valid view poses
imported a camera texture
submitted a layer
rendered the expected projection
```

Keep these as separate readiness layers. An app or Manifold adapter can expose
metadata and accepted session/stream references, while the foreground XR app
owns the frame loop, camera texture import, source sampling, projection math,
controller actions, and layer submission. High-rate media uses its dedicated
route; Manifold control/status payloads do not become the media plane.

## Useful Status Fields

Use names like these, adapted to the app:

```json
{
  "schemaVersion": "example.quest.status.v1",
  "app": {
    "package": "<package>",
    "foreground": true,
    "activity": "<activity>"
  },
  "clock": {
    "epochId": "<epoch>",
    "monotonicNanos": 0
  },
  "camera": {
    "permission": "granted",
    "headsetCameraPermission": "granted",
    "sourceKind": "direct-camera2",
    "width": 1280,
    "height": 960,
    "fps": 60
  },
  "render": {
    "openXrSession": "running",
    "lastFrameIndex": 0,
    "lastSubmitNanos": 0,
    "projectionMode": "<mode>"
  },
  "shellHelper": {
    "connected": true,
    "watchdog": {
      "enabled": true,
      "virtualProximityState": "CLOSE",
      "wakefulness": "Awake"
    }
  }
}
```

## Command Acknowledgements

Commands should return an acknowledgement separate from eventual render
success:

```json
{
  "commandId": "<id>",
  "accepted": true,
  "startedAt": "<iso8601>",
  "expectedEffect": "will-update-runtime-property"
}
```

Then expose the observed effect in `/status` or event streams. This prevents a
test from treating "command accepted" as "effect visible in headset."

## Binary Media Boundary

Do not send high-rate camera/video frames through generic JSON status or event
channels. Use typed metadata and command events for control, and a dedicated
media route for encoded packets, hardware buffers, or app-private texture
imports.

## Evidence Checklist

For every local endpoint probe, save:

```text
ADB forward command
endpoint URL
response JSON
app/package foreground before and after if relevant
clock/timebase response when available
logcat window around the command
```
