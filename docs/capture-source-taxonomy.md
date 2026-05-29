# Capture Source Taxonomy

Quest validation often fails because two screenshots look similar but came
from different parts of the system. Keep the capture source explicit in every
artifact name and report.

## Sources

| Source | What it proves | What it does not prove |
| --- | --- | --- |
| Native passthrough compositor | The runtime is presenting MR background to the user | App access to raw camera frames |
| Raw camera / Camera2 / Passthrough Camera API | App-visible camera frames and Camera2 metadata | Final headset display appearance |
| Environment depth | Runtime-provided depth data and metadata | RGB camera content |
| MediaProjection | Flattened app/display pixels after user consent | Raw camera or protected compositor content |
| ADB screencap | Still image of what Android exposes to screenshot capture | Full fidelity of protected compositor layers |
| `hzdb` screenshot | Quest-specific capture route when available | It still has provider-specific timing and policy |
| Casting/screenrecord | Operator-visible presentation over a transport | Raw camera texture data |
| Direct stream frame/status | Frame or metadata pulled from an app, VNC, MJPEG, or broker endpoint | Proof that the headset display or compositor presented the same content |
| App-private diagnostics | Internal renderer/camera counters and metadata | User-visible proof unless paired with capture |

## Naming

Use filenames that encode source and timing:

```text
<case>-adb-screencap.png
<case>-hzdb-screencap.png
<case>-mediaprojection.png
<case>-camera-probe.json
<case>-broker-status.json
<case>-stream-status.json
<case>-stream-frame.jpg
<case>-logcat-window.txt
<case>-freshness-summary.json
```

## Freshness

For live camera/render tests, one still image is not enough. Capture a short
sequence and compare hashes or pixel statistics:

```text
frame count
interval
unique hash count
black-like frame count
substantial-content count
```

Byte-identical screenshots may be fine for static UI. They are suspicious for
live camera evidence unless the scene is intentionally frozen.

For live localhost streams, prefer pulling a direct frame or status endpoint
over screenshotting a visible browser or cast window. Window captures are useful
human-observer evidence, but they depend on host foreground, window geometry,
and desktop capture policy.

## Screen Pixels Are Not A Global Ruler

Headset mirror screenshots can be curved, cropped, warped, or compositor
specific. Use screenshot-pixel measurements as evidence, not as the only source
of projection truth. If a test needs screen-space coordinate evidence, render
fiducials and estimate a local display-eye-UV-to-screenshot mapping.
