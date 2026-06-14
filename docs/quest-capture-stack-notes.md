# Quest Capture Stack Notes

This note keeps Quest display-capture routes separate so agents can choose a
recording path without rediscovering system boundaries.

## Built-In Sharing Recorder

Meta documents headset video capture through the Sharing menu and MQDH UI. In
the current `hzdb` command surface checked on 2026-06-14, `capture` exposes
`screenshot` only; it does not expose a public video recording subcommand.

The headset package `com.oculus.metacam` exposes capture metadata, but that is
not the same as a stable ADB recorder API:

- `com.oculus.metacam/.capture.CaptureService` is exported and has intent
  actions for `horizonos.appactions.START_RECORDING`,
  `horizonos.appactions.STOP_RECORDING`, and
  `horizonos.appactions.CAPTURE_PHOTO`.
- The service is protected by
  `com.oculus.permission.METACAM_SCREEN_CAPTURE`.
- `dumpsys app_function` lists Metacam App Functions for `capturePhoto`,
  `startRecording`, and `stopRecording`, with a
  `MetaCamCaptureResult` response.
- `cmd app_function` with no arguments dumps the App Function registry on the
  tested headset, but subcommands such as `help`, `list`, `execute`, `run`,
  and `call` report `No shell command implementation`. Treat it as an
  inspection surface, not an execution surface, on that build.
- Raw `adb shell am startservice` calls to the service actions return success
  at the Activity Manager level, but Metacam logs
  `Missing result messenger` and no new MP4/JPG is produced.
- A minimal debug APK using `AppFunctionManager.executeAppFunction()` can reach
  the platform API, but a normal/debug caller is denied with
  `Caller does not have permission to execute the appfunction`. Device
  permission metadata reports `android.permission.EXECUTE_APP_FUNCTIONS` as
  `internal|privileged`, and `pm grant` reports that it is not a changeable
  permission type.

Treat the built-in recorder as UI or Meta-tool owned unless a future build
exposes a documented shell execution path for App Functions or recording.

A follow-up UIAutomator sweep on 2026-06-14 proved that the visible Metacam
Android panel can be automated even though the raw service and App Function
paths remain blocked:

- `com.oculus.metacam/com.oculus.panelapp.sharing.SharingPanelActivity` can be
  launched with an explicit `am start`.
- UIAutomator exposes a clickable
  `com.oculus.metacam:id/screenrecording_button` node. Before recording, the
  visible tile text is `Record video`.
- Tapping that node through UIAutomator starts the built-in recorder. During
  recording, the same node remains exposed, the tile text changes to
  `Recording`, and `com.oculus.metacam:id/octile_active_indicator_view`
  appears.
- Relaunching the sharing panel and tapping the same node stops recording. A
  short probe produced a new MP4 in `/sdcard/Oculus/VideoShots/`.
- `dumpsys media_projection` stayed `null` before, during, and after the
  built-in recorder probe, so the built-in recorder does not appear as a
  normal app-visible MediaProjection manager session on the tested build.
- The camera settings menu is UIAutomator-visible. It exposes `Include mic
  audio`, camera-view selection, aspect-ratio selection, and a deeper
  `com.oculus.panelapp.settings` camera page with toggles for `Casting and
  recording indicator`, `Hide camera and call controls in captured or shared
  view`, plus capture-marker and aspect-ratio controls.
- A deeper UIAutomator sweep found that scrolling
  `com.oculus.panelapp.settings:id/settings_recycler_view` reveals advanced
  capture settings: `Format and quality`, `Bit rate`, `Frame rate`, `Image
  stabilization`, and `Eye perspective`.
- The reliable scroll routes were AndroidX `UiObject2.scroll(Direction.DOWN,
  ...)` and direct accessibility `ACTION_SCROLL_FORWARD` on the settings
  recycler. Legacy `UiScrollable` was unreliable on the same resource ID.
- On the tested Quest OS build, `adb shell input` did not list a `scroll`
  command or a `rotaryencoder` source. Display-targeted shell swipe worked for
  the active settings panel with `input touchscreen -d 0 swipe ...`; other
  visible display IDs were either no-ops or affected background panels.
- `am start -W -a android.settings.SETTINGS` opens Meta's Quest settings panel
  (`com.oculus.panelapp.settings`) with accessible, scrollable side-nav and
  content recycler nodes. `UiDevice.openQuickSettings()` and
  `UiDevice.openNotification()` did not expose distinct Quest quick-settings or
  notification surfaces in this probe.
- A follow-up settings navigation sweep reached Quest settings side-nav
  sections by resource ID: Link, General, Action button, Notifications,
  Environment setup, Movement, Tracking, Accessibility, Display & brightness,
  Audio, Camera, Privacy & safety, Passcode & security, Experimental,
  Developer, and Help. Keep these as open/dump routes only unless explicitly
  testing a setting change.
- For lower side-nav entries, AndroidX side-nav scrolling can be inconsistent.
  A side-nav lane swipe around x=170 combined with resource-id re-querying
  reached Camera, Developer, and Help when `UiObject2.scroll()` alone was not
  sufficient. Do not use generic text matching for navigation because it can
  click page headers instead of side-nav items.
- The non-mutating section crawler can then scroll the main settings recycler
  and emit per-page text/action summaries. In the tested state, Camera has
  multiple pages: recorder indicator and hidden captured controls, capture
  markers and aspect ratio, then microphone audio, bit rate, frame rate, image
  stabilization, eye perspective, and video coding format. Experimental also
  spans multiple pages, including hidden controls, external microphone, screen
  reader, adaptive brightness, temporal dimming, positional time warp,
  lying-down apps, Wi-Fi QR, seamless multitasking, and surface keyboard.
- The allowlisted child-page probe can open non-toggle settings rows and return
  with Back. `Privacy & safety > Device permissions` and `Privacy & safety >
  App permissions` opened real child pages in the tested state. Camera selector
  rows such as bit rate, image stabilization, and eye perspective were visible
  and clickable. A follow-up action-mode sweep activated those camera rows via
  coordinate tap, `UiObject2.click()`, and accessibility `ACTION_CLICK`, but
  still did not expose a distinct options surface; `ACTION_EXPAND` was not
  exposed on the safe row targets. Help rows are active external surfaces:
  `Help & Tips app` opens `com.oculus.helpcenter`, and `Support` can surface
  Help Center plus SystemUX support/report UI.
- A focused dropdown sweep showed the correct target for camera selector
  options is the compact `dropdown_button`/`android.widget.Spinner`, not the
  broad `settings_list_item` row. With `childTargetRole=dropdown`, coordinate
  tap, `UiObject2.click()`, and accessibility `ACTION_CLICK` all opened
  `context_menu_list` popovers for bit rate, frame rate, image stabilization,
  and eye perspective. Observed options were: bit rate `3 mbps (Default)`,
  `6 mbps`, `9 mbps`, `14 mbps`; frame rate `30 fps (Default)`, `60 fps`;
  stabilization `Off (Default)`, `Low`, `Medium`, `High`; eye perspective
  `Left eye (Default)`, `Right eye`. Do not select a different option unless a
  future test explicitly scopes and records that mutation.
- The current automation summary emits `settingsDropdownOptions` after a
  dropdown opens. Each option row records the `item_title` text, bounds,
  `selected`, `checked`, and `hasDefaultMarker`, which is the preferred compact
  evidence shape for capture-setting selector popovers.
- A guarded option-target dry-run was added to the automation APK. Passing
  `optionTarget` or `optionTargets` with `allowOptionSelect=false` finds and
  records a specific dropdown option row without selecting it. A 2026-06-14
  sweep matched bit rate `9 mbps`, frame rate `60 fps`, image stabilization
  `High`, and eye perspective `Right eye`; all returned the dry-run refusal
  reason and none changed settings.
- A full non-mutating Quest Settings section crawl reached all known top-level
  side-nav entries with object scrolling. Most sections fit on one page.
  Multi-page sections observed were Camera, Movement, Experimental, and
  Notifications. Notifications reached a true endpoint after five successful
  content scrolls and six pages; raw per-app notification names should stay in
  local reports, not public docs.
- Before copying sweep results into public docs, run the host-side report
  exporter. It emits page counts, scroll endpoint status, allowlisted setting
  labels, dropdown option evidence, and redaction counts while omitting raw XML
  paths, local paths, package/resource IDs, and unknown labels such as
  installed app names.

```powershell
python examples\quest-ui-automation\tools\summarize_report.py .\artifacts\quest-uiautomator\report.jsonl --format markdown
```

- Section crawler pages can emit `settings_section_route_inventory` events.
  A 2026-06-14 focused sweep verified the cleaned classifier: General exposed
  `child_page` routes, Camera exposed `dropdown` routes across three pages,
  Privacy & safety exposed sensitive `child_page` routes, and Help exposed
  external-surface `child_page` routes. Use the exporter output as the public
  evidence shape; keep raw row labels local.
- Meta Quest Scriptable Testing services are exposed through
  `content://com.oculus.rc` on the tested headset, implemented by
  `oculus.platform/oculus.internal.rc.RemoteControlProvider`.
  `GET_PROPERTY` is the safe read-only probe and returned keys for
  boundary/Guardian, proximity-close, blocking dialogs, and auto-sleep state.
  Treat `SET_PROPERTY`, `WIPE_DEVICE`, and `SETUP_FOR_TEST` as mutating
  commands requiring explicit approval, credentials/PIN where applicable, and
  a rollback/reset plan.
- `currentWindow` and `surfaceMap` reports now have a redacted exporter path.
  Use it for baseline/window/action-map notes instead of copying raw reports.
  It emits structural counts such as XML node counts, display IDs,
  accessibility-window counts, and action-node counts, while omitting package
  names, raw UI text, XML paths, window titles, and shell command output. A
  2026-06-14 baseline run also confirmed host-side
  `uiautomator dump --compressed` writes parseable XML, but node coverage
  differs from the instrumentation hierarchy.
- `scrollProbe` reports also have a redacted summary path. A focused
  `metacamDeepSettings` key-scroll sweep found `KEYCODE_DPAD_DOWN` and
  `KEYCODE_SPACE` can change visible state, while `KEYCODE_PAGE_DOWN` and
  `KEYCODE_TAB` did not. Treat key events as focus/search/navigation signals,
  not reliable settings-list scrolling; prefer `uiObject2` or accessibility
  scroll actions for content movement.

Treat this as UI-driven automation, not a stable recorder CLI. Prefer
resource-id based UIAutomator dumps and taps; do not rely on fixed
coordinates, and do not pull generated MP4 media into public repos.

If this route is triggered through an off-LAN Termux agent, wrap it as a typed
`uiautomator.run_allowlisted_scenario` command under an active remote-session
lease. Return redacted exporter summaries by default. Keep built-in-recorder
MP4s, raw UI XML, screenshots, logcat, local paths, device serials, installed
app names, and private package IDs in local evidence only.

Useful inspection commands:

```powershell
adb -s <serial> shell dumpsys package com.oculus.metacam
adb -s <serial> shell dumpsys app_function
adb -s <serial> shell cmd app_function help
adb -s <serial> shell dumpsys media_projection
adb -s <serial> shell ls -la /sdcard/Oculus/VideoShots
adb -s <serial> shell ls -la /sdcard/Oculus/Screenshots
```

Direct service calls can be used only as a diagnostic probe:

```powershell
adb -s <serial> logcat -c
adb -s <serial> shell am startservice -a horizonos.appactions.START_RECORDING -n com.oculus.metacam/.capture.CaptureService
Start-Sleep -Seconds 5
adb -s <serial> shell am startservice -a horizonos.appactions.STOP_RECORDING -n com.oculus.metacam/.capture.CaptureService
adb -s <serial> logcat -d -v threadtime -t 1000
```

Expected failure mode for raw shell invocation on the tested build:
`MetaCam (CaptureService): Missing result messenger`.

Expected failure mode for normal APK App Function invocation on the tested
build:
`Caller does not have permission to execute the appfunction`.

Recorder quality, eye selection, microphone, shortcut, and indicator controls
show up as internal Metacam strings and settings concepts. Some are reachable
through UIAutomator-driven Android settings panels, but no public
`settings global|secure|system` key or documented ADB knob was found for them
in the sweep. Do not document the red recording indicator, bitrate,
resolution, eye, or audio settings as directly ADB-controllable unless a future
run proves the exact supported setting or App Function call surface.

## ADB `screenrecord`

Plain Android `screenrecord` is available on the tested headset and can write
an MP4 over ADB:

```powershell
adb -s <serial> shell screenrecord --verbose --size 3664x1920 --bit-rate 40M --time-limit 2 /sdcard/Download/capture-probe.mp4
adb -s <serial> pull /sdcard/Download/capture-probe.mp4 .
```

On the tested Quest 3S route this produced H.264 video at 3664x1920, roughly
67 fps over a two-second sample, with the recorder configured for the physical
headset display. A frame inspection showed a raw stereo headset view with
left/right eye images, not a polished single flat spectator/onboarding view.

Use `screenrecord` as a diagnostic witness for raw display output. Do not use
it as the default source for public onboarding clips when the target is a
single coherent flat capture.

## MediaProjection Frame Streams

MediaProjection is the app-owned route when the goal is live pixels rather
than a polished user recording. It gives the app a consented final
display/app-window composite stream. It is not raw headset camera data and it
is not a privileged compositor layer hook.

Android's MediaProjection guidance requires `FOREGROUND_SERVICE` plus
`FOREGROUND_SERVICE_MEDIA_PROJECTION` for target SDK 34+ foreground services,
and requires user consent before each MediaProjection session. See Android's
[Media projection guide](https://developer.android.com/media/grow/media-projection)
and [foreground service type guidance](https://developer.android.com/develop/background-work/services/fgs/service-types#media-projection).

The reusable pattern used by the Rusty XR public example is:

1. The foreground activity calls
   `MediaProjectionManager.createScreenCaptureIntent()`.
2. After user consent, the activity receives `resultCode` and `resultData` in
   `onActivityResult`.
3. The activity starts a non-exported foreground service with foreground
   service type `mediaProjection`.
4. The service calls `getMediaProjection(resultCode, resultData)`.
5. The service creates an `ImageReader` with `PixelFormat.RGBA_8888`.
6. The service calls `createVirtualDisplay(...)` using the
   `ImageReader.getSurface()`.
7. On each `ImageReader` callback, the service uses `acquireLatestImage()`,
   copies rows into a tight RGBA payload respecting row stride and pixel
   stride, and writes frames to a receiver.
8. The receiver stores a ledger keyed by frame index, timestamp, width, height,
   format, and stream label.

A 2026-06-14 Quest 3S probe confirmed the normal app route:

- `FOREGROUND_SERVICE` and
  `FOREGROUND_SERVICE_MEDIA_PROJECTION` are install-time granted to a normal
  debug app when declared in the manifest.
- `MANAGE_MEDIA_PROJECTION`, `CAPTURE_VIDEO_OUTPUT`,
  `CAPTURE_SECURE_VIDEO_OUTPUT`, and `CAPTURE_MEDIA_OUTPUT` remain denied to a
  normal debug app. `pm grant` reports the privileged capture permissions as
  role-managed, and reports the foreground-service media projection permission
  as not a changeable permission type.
- `cmd media_projection` exists only as a dump surface on the tested build; it
  reports `No shell command implementation` for command-style use.
- Without a real `resultData` token from `createScreenCaptureIntent()`,
  `MediaProjectionManager.getMediaProjection(Activity.RESULT_OK, new Intent())`
  returns `null`; app permissions or app-ops alone do not create a capture
  token.
- After consent, `getMediaProjection(resultCode, resultData)` returns a token,
  `createVirtualDisplay()` succeeds, `dumpsys media_projection` shows the
  calling package as an active `TYPE_SCREEN_CAPTURE`, and an `ImageReader`
  receives frames.
- Android 14 single-use behavior is enforced. A second
  `createVirtualDisplay()` call on the same `MediaProjection` instance throws
  `SecurityException` with guidance not to reuse `resultData` or invoke
  multiple captures from one token.

The Rusty XR sample protocol is a 4-byte little-endian JSON header length,
then the JSON header, then the raw payload. Example header fields:

```json
{
  "byte_len": 589824,
  "frame_index": 0,
  "timestamp_ns": 123456789,
  "width": 512,
  "height": 288,
  "format": "rgba8888",
  "stream": "display_composite"
}
```

Companion receiver shape:

```powershell
dotnet run --project src\RustyXr.Companion.Cli -- media reverse --serial <serial> --device-port 8787 --host-port 8787
dotnet run --project src\RustyXr.Companion.Cli -- media receive --port 8787 --out .\artifacts\media-stream --once
```

MediaProjection still requires headset/user consent in normal app flows. The
tested Quest prompt was exposed to UIAutomator as
`com.meta.systemui/.media.MediaProjectionPermissionActivity` with a `Share`
button and warning text that the app can capture the headset view, including
physical surroundings. ADB input could tap that system dialog on the tested
build, but this only proves that specific Android system UI path, not OpenXR
controller or app interaction.
The current prompt is a two-step surface when app-window selection is enabled:
the approval button is visible but disabled until a target is chosen. A
2026-06-14 UIAutomator probe saw one full-view target and multiple generic
app-window targets, tapped the full-view target, then tapped the now-enabled
approval button. The probe Activity received `RESULT_OK` with result data. A
cancel-only run returned `RESULT_CANCELED` with no result data. Because this
probe only mapped the prompt and did not call `getMediaProjection()` or
`createVirtualDisplay()`, `dumpsys media_projection` stayed `null`.

For Quest Settings mapping, the questionnaire panel repo's
`examples/quest-ui-automation/tools/summarize_report.py` can turn
`settings_section_route_inventory` events into a follow-up child-page probe
plan with `--format child-targets`. Its default planner includes only
public-safe `child_page` routes in the `open_dump_only` bucket and excludes
default-blocked rows such as Software update and Cloud backup. A 2026-06-14
focused General-section run used that route to open Quick controls, Storage,
and Ongoing activities with compact child-page dumps and Back return.
The same route-plan flow also opened low-risk Environment setup,
Accessibility, and Audio child pages: Boundary, Travel mode, Vision, Mobility,
Hearing, and Spatial audio for windows.

For lab automation, ADB can set the `PROJECT_MEDIA` app-op:

```powershell
adb -s <serial> shell cmd appops set <package> PROJECT_MEDIA allow
adb -s <serial> shell am start -a <app-action-that-calls-createScreenCaptureIntent> -n <package>/<activity>
adb -s <serial> shell cmd appops set <package> PROJECT_MEDIA default
```

On the tested build, this app-op pregrant allowed the app's normal
`createScreenCaptureIntent()` flow to return an approved `resultData` token
without a visible prompt. It did not let the app skip the API flow: directly
calling `getMediaProjection()` with a fabricated `Intent` still returned
`null`. Treat `PROJECT_MEDIA` as an ADB-only lab pregrant, reset it after the
run, and do not ship or document it as an in-app permission request.

## Decision Guidance

Use the built-in Sharing recorder or MQDH when a human can operate the UI and
the target is a polished MP4. Use MediaProjection when an app or companion
needs immediate frames for validation, feedback loops, or receiver-side
analysis. Use `hzdb` or ADB screenshots when one still image is enough. Label
each artifact by route.
