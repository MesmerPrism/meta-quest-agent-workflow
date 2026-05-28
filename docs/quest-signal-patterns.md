# Quest Signal Patterns And Screenshot Readiness

This guide collects practical Quest validation signals for agents. The goal is
to avoid taking screenshots or accepting runs before the device and app are
actually ready.

## Readiness Ladder

Use a ladder, not one boolean:

| Level | Meaning | Typical evidence |
| --- | --- | --- |
| ADB reachable | Host can talk to the headset. | `adb devices -l`, basic `getprop`. |
| Display ready | Headset appears awake/display-on. | `dumpsys power`, screenshot non-empty. |
| App launch ready | Target can be foregrounded. | `am start` success, focused window. |
| Broker/service ready | Local status endpoint responds. | `/status`, `/clock/now`, command ack. |
| OpenXR ready | Immersive app has session/frame loop. | lifecycle logs, `READY`/`FOCUSED`, frame counter. |
| Source ready | Camera/video/synthetic source is producing frames. | source metadata, frame sequence progression. |
| Projection/render ready | The renderer has bound source and submitted visible frames. | projection contract, final status, visible screenshot. |
| Capture ready | The capture route has a fresh witness after readiness. | readiness marker, settle delay, screenshot/hash. |

For camera work, `display ready` and `app launch ready` do not imply
`camera ready`.

## Good Screenshot Timing

Prefer readiness-timed capture:

1. Clear or start a bounded logcat window before launch.
2. Launch the app or profile.
3. Poll the live log file for a readiness marker.
4. After marker detection, wait a short settle interval.
5. Take the screenshot.
6. Stop the log window and save the readiness summary.

For camera/projection apps, useful readiness markers include:

```text
source-sampling
source_sampling
projection-coordinate
projection_coordinate
projection contract
source metadata
final projection status
OpenXR frame
visibleCameraProjectionReady=true
RUSTY_XR_MAKEPAD_OPENXR_END_FRAME
RUSTY_XR_MAKEPAD_CADENCE ... xrUpdateRateHz=<nonzero>
```

These names come from one public renderer family, but the pattern is generic:
capture after an app-authored source/render readiness marker, not after a fixed
sleep alone.

If readiness polling times out, classify the run as `timeout` or `needs
evidence`. Do not silently treat the fixed timeout as success.

## Logcat Window Ownership

For controlled runs, the harness should own the logcat window:

```powershell
adb -s <serial> logcat -c
adb -s <serial> logcat -v threadtime > <out-dir>\logcat-window.txt
```

When a process reads a log file while ADB is still writing it, the reader must
open it with shared read/write access. Otherwise the harness can miss real
markers until timeout and make the run look slower or less deterministic than
it is.

## Critical Signals

Reject or bracket a run when logs contain signals like:

```text
automation_disable
setVirtualProxState(DISABLED)
Going to sleep
Sleeping power group
Powering off display group
SCREEN_OFF
XR_SESSION_STATE_*_EXITING
RequestExitSession
```

Treat these as power/session contamination until the run proves recovery and
re-establishes readiness.

## Warning Signals

Warnings require interpretation:

```text
Start sleep timeout
Sleep timeout exceeded
WaitForWake
Invalid PTS from input surface: 0
Camera watchdog/probe warnings
Camera stream timestamp not increasing
Stereo camera pair exceeded soft timestamp target
Compositor slice tear due to CPU delay
```

Warnings do not always invalidate a run, but they should appear in the
artifact summary.

## OpenXR Signals

Healthy immersive path:

- Android activity resumed, focused, and native window initialized before
  session setup.
- OpenXR reaches visible/focused state.
- Frame counter advances.
- `xrEndFrame` or equivalent submit markers appear.

Problem patterns:

- resumed/paused/focused/lost-focus/window-init/window-terminated loop;
- OpenXR view pose invalid for every frame;
- no rendered frames after app foreground;
- frame loop alive but no source frames.

Add a bright fallback clear or test pattern before camera frames arrive. That
separates "renderer alive" from "camera source alive".

## Camera And Video Signals

For live camera/video runs, require frame progression:

- source frame sequence increases;
- texture/update/import sequence increases;
- OpenXR frame count increases;
- source-to-render relationship is plausible;
- screenshots show non-black content in expected ROIs or a visible diagnostic
  stimulus.

Repeated screenshots with identical hashes can be valid for static content,
but they are suspicious for live camera unless the app reports frame
progression. Use a moving marker or changing counter when freshness matters.

Stale camera pattern:

```text
OpenXR frame count advances hundreds of frames
camera frame count barely advances
camera/open/capture warnings present
screenshots look static or black
```

This should be investigated as source/provider/acquisition readiness, not as a
projection geometry issue.

## Screenshot Interpretation

Screenshot pixels are evidence, not geometry truth by themselves.

- Mirror/screenshot space can be warped, cropped, or scaled relative to
  display-eye UV.
- Analyzer boxes measure observed pixels after segmentation, not the renderer's
  intended source-valid footprint.
- Use renderer-authored contracts, source metadata, and app logs to interpret
  screenshot measurements.
- A full-frame diagnostic stimulus is better than natural camera imagery when
  testing orientation, stretch, edge sampling, or projection footprint.

## MediaProjection Signals

MediaProjection requires user consent and, on recent Android versions, a
single-use token for each capture session. On Quest, there may be an additional
headset selector such as "Select view you want to share". If this prompt is
waiting, the app may be correct and the capture route blocked.

Do not use scripted taps as durable evidence for MediaProjection consent. Ask
the operator to approve in-headset, or mark the run blocked.

## Permission Signals

Permission problems often show up as one of:

- `SecurityException`;
- "missing uses-permission string ...";
- `pm grant` says permission is not changeable;
- camera opens fail even though APK install succeeded;
- app waits for a headset permission prompt.

If a log names a missing manifest permission, add that manifest declaration in
the app build. If `pm grant` reports "not a changeable permission type", do not
keep retrying; capture the line and use the correct manifest/headset/provider
route.

## hzdb / HDB Permission Notes

Some teams refer to Meta Horizon Debug Bridge as `hzdb`, and some shorthand it
as "hdb". Treat it as an optional provider. Command groups can change, so the
safe pattern is:

```powershell
npx -y @meta-quest/hzdb --version
npx -y @meta-quest/hzdb --help
npx -y @meta-quest/hzdb app --help
```

If the installed `hzdb` build exposes an app-permission or app-op command, use
that and save the exact command plus version. Otherwise use the ADB fallback:

```powershell
adb -s <serial> shell pm grant <package> <permission>
adb -s <serial> shell appops set <package> <op> allow
adb -s <serial> shell dumpsys package <package> > <out-dir>\dumpsys-package.txt
adb -s <serial> shell appops get <package> > <out-dir>\appops.txt
```

Always capture readback. A successful grant command is not enough if the app
still lacks the manifest permission or the platform requires headset consent.
