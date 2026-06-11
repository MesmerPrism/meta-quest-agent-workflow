# Termux And Linux Sidecars

Termux can be useful on Quest as a visible developer lab sidecar. Treat it as
a normal Android app, not as Android `shell`, not as HOME, not as a kiosk
policy engine, not as an XR runtime authority, and not as a hidden watchdog.

## Good Uses

- CLI diagnostics and package experiments.
- Local static dashboards bound to device localhost.
- Headless localhost command/status services for foreground headset apps.
- Termux:X11 foreground panels for small X11 clients.
- Proot CLI tools and small GUI client experiments.
- Host-visible evidence capture and direct stream-frame pulls through explicit
  ADB forwarding.

## Boundaries

- Termux does not gain `shell` identity by being installed on the headset.
- Android `am`, `pm`, and `cmd` behavior from the Termux app UID can be useful
  for queries while still being blocked for privileged or cross-package actions.
- ADB from inside Termux still depends on normal user authorization and should
  be treated as externally leased developer access.
- If Termux runs an ADB client against `127.0.0.1:5555`, require
  `adb shell id` to report `uid=2000(shell)` before install, launch, logcat,
  wake, or package-management commands.
- Termux ADB subprocesses need a writable temporary directory. Use `TMPDIR`
  when already set, or create `$PREFIX/tmp` before starting ADB.
- APKs for Termux-mediated installs should live in a path the Termux process
  can read. Prefer Termux-private storage or an explicitly staged readable
  path; do not assume public shared storage is readable from every
  non-interactive Termux execution context.
- Termux:Boot, wake locks, full desktop environments, audio servers, remote
  shell services, graphics acceleration, and LAN-visible VNC all require
  separate gates.

## Loopback ADB Install/Update

After an operator or external workflow enables WiFi ADB, Termux can run:

```sh
export TMPDIR="${TMPDIR:-$PREFIX/tmp}"
mkdir -p "$TMPDIR"
adb connect 127.0.0.1:5555
adb -s 127.0.0.1:5555 shell id
```

The pass condition is Android shell UID:

```text
uid=2000(shell)
```

When that gate passes, Termux may use the leased ADB shell for bounded
developer operations such as `adb install -r`, allowlisted `am start`, focused
`dumpsys`, or bounded logcat. This can avoid Android's normal installer
confirmation because the install authority is ADB shell, not the Termux app
UID. It still does not prove reboot durability, device-owner management, MDM,
or app-side silent updates.

Keep artifact staging explicit. A Termux-owned updater should download into a
Termux workspace or another readable path. A host-staged `/data/local/tmp` APK
is acceptable lab plumbing when recorded as external ADB workflow state, but it
should not become the default app communication or update channel.

When the headset has internet but is not on the same WiFi as the operator
machine, trigger updates through outbound control. The operator or CI publishes
a verified APK manifest to an HTTPS controller; the Termux agent polls outbound,
downloads the APK, checks the loopback ADB shell gate, and installs locally.
Do not require inbound ADB, a public headset listener, or shared LAN reachability
for the normal trigger path. Use direct external ADB only for local setup and
recovery.

## Visible Helper Restart

A normal Android helper can restart a stopped Termux fleet agent when all of
these conditions are true:

- the helper is installed and operator-visible;
- the helper has been granted `com.termux.permission.RUN_COMMAND`;
- Termux is configured to allow external commands, for example
  `allow-external-apps=true`;
- the helper calls Termux's `RunCommandService` with `startForegroundService()`
  on Android 8+;
- the command is a fixed reviewed starter for the fleet agent, not a generic
  remote shell.

A live Quest run force-stopped `com.termux`, launched the helper Activity with
an auto-start extra, and observed Termux plus
`python termux_fleet_agent.py --config config.json` running again. The
controller received fresh heartbeats, and the latest heartbeat reported
`central_reachable=true`, `local_adb.available=true`, and
`local_adb.shell_uid=2000`.

Use this as operator-visible stopped-process recovery only. It does not restore
WiFi ADB after reboot, make Termux or the helper Android `shell`, bypass user
debugging authorization, or provide a managed-device update channel.

## Headless Sidecar Notes

For many XR workflows, a visible Linux desktop is unnecessary. A small
Termux-owned command/status service bound to device localhost can let a
foreground headset app request allowlisted Linux-side work and receive
structured results.

Initial Quest validation showed a Termux localhost JSON service can continue
answering status and command requests while another headset app is foregrounded
and no X11 desktop surface is visible.

Keep this route constrained:

- bind to localhost by default;
- use allowlisted commands and argument schemas;
- return structured stdout, stderr, exit code, timing, and status;
- include timeouts, cancellation, and audit/event records;
- add authentication or a local capability token before product use;
- treat long-running survival across sleep, reboot, and battery policy as a
  separate gate.

## Termux:X11 Notes

Start with the smallest visible X11 client before trying a full desktop. Record
the actual operator interaction needed to focus or move the pointer; on Quest,
panel focus can behave differently from a desktop mouse hover.

Basic terminal typing can work, but display geometry and text-heavy layouts
need their own validation. Do not promote a text editor or full desktop recipe
until the panel size, input focus, keyboard behavior, and cleanup path are
repeatable.

Native phone-like Termux:X11 geometry can present more reliably in the headset
2D panel than resized landscape roots. Exact landscape Termux:X11 display
preferences can fix X-root/VNC left-slice output, but the Termux Android
activity may still stay constrained or letterboxed. If a landscape X root is
visible through VNC but black, cropped, or incomplete in the headset panel,
classify that as an evidence route or geometry distinction, not automatically
as a Linux process failure.

Do not rely on shell-level Android task resize as a panel correction workflow.
It can mismatch task/root bounds and crop the desktop. For headset-visible
full-desktop observation, prefer a separate landscape viewer panel that
consumes a localhost-only VNC/MJPEG bridge. Initial validation shows this route
can present a full 1280x720 desktop stream in a Quest 2D panel.

## Proot Notes

Proot is useful for Linux userland packages, but GUI compatibility is
package-specific and performance can vary. Keep Proot as a lab affordance until
the exact package, display route, and cleanup behavior are known.

## VNC Notes

Use VNC only as a bounded visibility route:

```powershell
adb -s <serial> forward tcp:<host-port> tcp:<device-port>
```

Safe defaults:

- bind the VNC server to localhost when possible;
- use ADB forwarding for host access;
- capture the evidence needed, preferably from a direct frame/status endpoint;
- stop the VNC server;
- remove the ADB forward;
- verify that no listener remains.

If a VNC server fails on Android shared-memory permissions, retry with an
explicit no-shared-memory mode and record the exact flags. VNC mirrors the X
display; it does not fix headset-side panel geometry.

Keep these witnesses separate:

- X-root evidence: VNC screenshots, MJPEG `/frame.jpg`, or stream
  `/status.json`.
- Headset-panel evidence: ADB or headset-provider screenshots of the Quest
  display.
- Viewer-panel evidence: a separate landscape Android panel showing the
  localhost MJPEG bridge.
- Human-observer evidence: browser-window or cast-window captures.

## Session Recipe Shape

Reduce desktop or Linux sidecar ideas to data-first session recipes before
running large bootstrap scripts:

```text
preflight
start
status
stop
cleanup
evidence
risk
authority boundary
```

Do not copy source from third-party desktop setup projects unless licensing and
attribution have been reviewed. Prefer original small recipes and synthetic
fixtures.

## Evidence Checklist

For each sidecar test, record:

- device model and Android version;
- provider used: ADB, app status endpoint, headset operator, or MCP;
- exact package/source family for Termux components;
- foreground surface before and after;
- process and listener snapshots;
- whether any headset prompt was intentional;
- cleanup verification.
