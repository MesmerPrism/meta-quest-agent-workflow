---
name: meta-quest-workflow
description: Use when working with Meta Quest headsets, ADB, Quest APK install/launch/validation, screenshots, logcat, Perfetto, Camera2 metadata, broker-style localhost probes, or Meta Horizon MCP/hzdb workflows.
---

# Meta Quest Workflow

Use this skill before an agent touches a Meta Quest headset, ADB transport,
APK install/launch, screenshots, logcat, Perfetto, camera metadata, or
Quest-specific MCP tooling.

This is a public, portable skill. It does not assume a particular machine,
repository, headset serial, app package, broker implementation, or MCP client.

## First Decisions

1. Identify whether the task is planning-only, read-only device inspection,
   bounded capture, app lifecycle, file mutation, device setting, shell command,
   network forwarding, or destructive cleanup.
2. If the task touches a shared headset, ADB server, long APK build, local port,
   or capture session, use the team's local resource-locking process before
   running commands.
3. Prefer read-only probes before side effects.
4. Preserve headset power, stay-awake, and proximity state unless the task
   explicitly asks to test or change those states.
5. Record evidence: command goal, provider, fallback, serial/model, package,
   foreground before/after, important status endpoints, artifact paths, and
   whether any headset prompt or Meta system panel was intentional.

## Provider Order

Use the narrowest provider that can answer the question:

1. App-owned or broker-style HTTP/WebSocket status endpoint for app health,
   clock, streams, and command acknowledgements.
2. Meta Horizon MCP / `hzdb` for Quest-specific docs, device status, logs,
   screenshots, Perfetto, and asset search when configured.
3. ADB for install, launch, logcat, screenshot, dumpsys, port forwarding, and
   file push/pull.
4. App-private diagnostics, usually pulled through `run-as` on debuggable
   builds.
5. Manual headset action for runtime permission prompts, MediaProjection
   consent, protected prompts, and real controller input.

Do not substitute one source for another without labeling it. ADB screenshot,
MediaProjection, casting, and headset camera frames are different witnesses.

## Safe ADB Baseline

Use an explicit serial when more than one Android device may be connected:

```powershell
adb devices -l
adb -s <serial> shell getprop ro.product.model
adb -s <serial> shell getprop ro.build.version.release
adb -s <serial> shell wm size
adb -s <serial> shell wm density
```

Focused foreground readback:

```powershell
adb -s <serial> shell dumpsys window | findstr /i "mCurrentFocus mFocusedApp"
```

Avoid broad, repeated `dumpsys activity activities` polling in tight loops
unless the extra detail is needed.

## APK Install, Grant, Launch

Install a development APK:

```powershell
adb -s <serial> install -r -d -g <path-to.apk>
```

Grant declared runtime permissions for unattended development runs:

```powershell
adb -s <serial> shell pm grant <package> android.permission.CAMERA
adb -s <serial> shell pm grant <package> horizonos.permission.HEADSET_CAMERA
adb -s <serial> shell pm grant <package> android.permission.POST_NOTIFICATIONS
```

Only grant permissions that the APK declares and the profile needs. Some
permissions are not changeable with `pm grant`; for those, manifest declaration
or headset UI approval is the relevant gate.

Optional app-specific grants, only when declared and needed:

```powershell
adb -s <serial> shell pm grant <package> com.oculus.permission.USE_SCENE
adb -s <serial> shell pm grant <package> horizonos.permission.USE_SCENE
adb -s <serial> shell pm grant <package> horizonos.permission.AVATAR_CAMERA
adb -s <serial> shell appops set <package> PROJECT_MEDIA allow
```

Launch:

```powershell
adb -s <serial> shell am start -n <package>/<activity>
```

Watch for failures:

```powershell
adb -s <serial> logcat -c
adb -s <serial> shell am start -n <package>/<activity>
Start-Sleep -Seconds 10
adb -s <serial> logcat -d -v threadtime > <out-dir>\logcat.txt
```

## Logcat And Screenshots

Clear logs immediately before a controlled launch if you need a bounded window:

```powershell
adb -s <serial> logcat -c
adb -s <serial> logcat -d -v threadtime > <out-dir>\logcat.txt
```

Take a simple screenshot:

```powershell
adb -s <serial> exec-out screencap -p > <out-dir>\screenshot.png
```

Treat screenshot timing and capture route as part of the evidence. ADB
screencap, Meta/hzdb capture, MediaProjection, casting, and screenrecord can
look similar but answer different questions.

## Capture Readiness Signals

For renderer or camera validation, capture after an app-owned readiness marker,
not immediately after `am start`.

Useful marker classes:

```text
source-sampling contract
projection-coordinate contract
OpenXR frame submitted
nonzero XR cadence
visible camera projection ready
first camera frame timestamp/source metadata
```

Recommended sequence:

```text
clear or start a bounded logcat window
launch app
wait for readiness marker or fixed warmup
settle briefly
capture screenshot or sequence
save logcat window and readiness summary
```

Reject or bracket captures if logs show sleep, standby, display power-off,
OpenXR session exit, fatal exception, or a protected system prompt that was not
part of the test.

## Camera Metadata

Start with pure ADB:

```powershell
adb -s <serial> shell dumpsys media.camera > <out-dir>\dumpsys-media-camera.txt
adb -s <serial> shell cmd media.camera dump > <out-dir>\cmd-media-camera-dump.txt 2>&1
```

If an app or broker can run a Camera2 probe, collect app-context metadata too.
Important fields are camera id, lens facing, physical/logical camera
relationship, output sizes, FPS ranges, active array, pixel array, crop region,
sensor orientation, intrinsic calibration, distortion when exposed, lens pose
translation/rotation/reference, and whether a short open/capture probe
succeeded.

Model names and camera ids are diagnostics from one runtime, not portable
constants. Treat per-device homography as runtime metadata or calibration, not
as a hard-coded value from another headset model.

## Long-Running Watchdogs

For long device workflows, a team may use either a host-side watchdog or an
ADB-launched device-side shell helper. The device-side helper is usually pushed
to `/data/local/tmp` and started with `app_process`; it is developer tooling,
not an installed app capability.

The watchdog should be idempotent:

```text
observe virtual proximity and wakefulness
reapply only after drift
report reapply counts through status
stop through an explicit operator action
keep restore of normal proximity as a separate action
```

Useful readbacks:

```powershell
adb -s <serial> shell dumpsys vrpowermanager
adb -s <serial> shell dumpsys power
adb -s <serial> shell input keyevent KEYCODE_WAKEUP
adb -s <serial> shell svc power stayon true
```

Use `hzdb device proximity --help` before relying on `hzdb` proximity commands,
because the exact command shape depends on the installed version.

## Capture Source Taxonomy

Keep these sources separate:

- Native passthrough compositor: user-facing MR background controlled by the
  runtime. It is not an app-sampleable texture in normal public app code.
- Raw camera / Passthrough Camera API / Camera2: app-visible frames and camera
  metadata. Use this for custom CV and camera projection.
- Environment depth: runtime depth texture and metadata. It is not raw RGB
  camera and not final-display capture.
- MediaProjection: flattened display or app-window pixels after user consent.
  Use it to inspect what was displayed, not to obtain raw camera frames.
- ADB or hzdb screenshot: still image witness with its own timing and capture
  policy.
- Casting or screenrecord: operator inspection of the presented display, not
  raw camera data.

## Tracking Boundary

Fused HMD and controller pose belongs in the active XR app's OpenXR session.
ADB, shell helpers, a 2D broker, and background services are useful for launch,
logs, status, and transport, but they are not a supported public backdoor to
another app's fused tracking stream.

If another process needs tracking, add a thin adapter to the foreground XR app:

```text
OpenXR frame loop
  -> locate views and action spaces at the selected XrTime
  -> record validity/tracked flags and timestamps
  -> publish sanitized snapshots to an app-owned UDP/TCP/WebSocket/broker route
```

ADB synthetic keys can test Android input routing. They do not prove Meta Touch
controller action bindings.

## Meta Horizon MCP And hzdb

Meta's Horizon Debug Bridge (`hzdb`) can be used as a CLI and MCP server when
available. Treat it as an optional Quest-specific provider beside ADB, not as a
required dependency.

Read-only setup checks:

```powershell
node --version
npx --version
npx -y @meta-quest/hzdb --version
```

Manual MCP server shape:

```json
{
  "servers": {
    "meta-horizon-mcp": {
      "command": "npx",
      "args": ["-y", "@meta-quest/hzdb", "mcp", "server"]
    }
  }
}
```

Choose one MCP registration route per agent or IDE. Do not register multiple
Meta Horizon MCP servers for the same agent unless the tool explicitly
supports that.

Use MCP/docs search to verify Quest-specific assumptions before editing
passthrough, camera, environment depth, input, performance capture, or Horizon
OS behavior. Gate device-changing MCP tools the same way you would gate the
equivalent ADB command.

## Broker-Style Localhost Pattern

A Quest app or sidecar broker can expose local status and command endpoints,
for example:

```text
http://127.0.0.1:<port>/status
http://127.0.0.1:<port>/clock/now
ws://127.0.0.1:<port>/<events-path>
```

Use ADB forwarding from the host:

```powershell
adb -s <serial> forward tcp:<host-port> tcp:<device-port>
curl.exe http://127.0.0.1:<host-port>/status
```

A broker can report metadata, streams, clocks, launch state, and diagnostic
probes. It does not own another foreground XR app's OpenXR frame loop, layer
submission, raw camera texture import, or controller action spaces.

## Termux And Linux Sidecars

Termux can be a useful Quest lab sidecar for CLI diagnostics, local dashboards,
Termux:X11 panels, Proot tools, and bounded localhost VNC evidence. Treat it as
a normal Android app, not Android `shell`, not HOME, not a kiosk policy engine,
not an XR runtime authority, and not a hidden watchdog.

Start with small visible tests:

```text
Termux CLI
Termux:X11 with one small X11 client
Proot CLI
Proot GUI client only after X11 is visible and stoppable
localhost dashboard or VNC only through an explicit forward
```

For VNC, bind to localhost when possible, use ADB forwarding, capture the
needed evidence, stop the server, remove the forward, and verify cleanup. If a
VNC server fails on Android shared-memory permissions, retry with an explicit
no-shared-memory mode and record the exact flags.

Reduce large desktop or Droid-style setup ideas to data-first session recipes:
preflight, start, status, stop, cleanup, evidence, risk, and authority
boundary. Do not copy third-party setup source without checking license and
attribution obligations.

## Side Effects And Gates

Use these default gates:

| Operation class | Default handling |
| --- | --- |
| Read-only status, docs, health, package info | Allowed after identifying target. |
| Bounded capture, screenshots, logcat, Perfetto | Allowed with artifact path and run label. |
| App lifecycle: install, launch, force-stop, clear | Explicit operator intent. |
| File read or pull | Explicit source and destination. |
| File write, push, delete | Explicit operator intent and dry-run when possible. |
| Device settings: stay-awake, proximity, sensor-lock, testing modes | Explicit intent, bounded duration, restore notes. |
| Shell helper, network forward, root-like commands | Explicit intent and audit trail. |

## Evidence Checklist

For any headset-facing run, capture:

- ADB or provider path and version.
- Serial and model.
- Command goal.
- Package/activity or endpoint.
- Foreground before/after if relevant.
- Permission grants or prompts.
- Status endpoint snapshots when available.
- Logcat file and screenshot path when captured.
- Whether a Meta system panel or headset permission prompt was intentional.
- Result and remaining uncertainty.

## References

See the repository `docs/` folder for focused playbooks:

- `docs/adb-basics.md`
- `docs/apk-install-launch.md`
- `docs/artifact-and-evidence-discipline.md`
- `docs/broker-style-localhost-probes.md`
- `docs/camera-metadata-collection.md`
- `docs/capture-source-taxonomy.md`
- `docs/long-running-watchdogs.md`
- `docs/termux-linux-sidecars.md`
- `docs/meta-horizon-mcp-and-hzdb.md`
- `docs/openxr-tracking-boundary.md`
- `docs/permissions-and-distribution-boundary.md`
- `docs/quest-signal-patterns.md`
- `docs/shell-helper-boundary.md`
- `docs/troubleshooting.md`
