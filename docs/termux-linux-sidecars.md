# Termux And Linux Sidecars

Termux can be useful on Quest as a visible developer lab sidecar. Treat it as
a normal Android app, not as Android `shell`, not as HOME, not as a kiosk
policy engine, not as an XR runtime authority, and not as a hidden watchdog.

## Good Uses

- CLI diagnostics and package experiments.
- Local static dashboards bound to device localhost.
- Termux:X11 foreground panels for small X11 clients.
- Proot CLI tools and small GUI client experiments.
- Host-visible evidence capture through explicit ADB forwarding.

## Boundaries

- Termux does not gain `shell` identity by being installed on the headset.
- Android `am`, `pm`, and `cmd` behavior from the Termux app UID can be useful
  for queries while still being blocked for privileged or cross-package actions.
- ADB from inside Termux still depends on normal user authorization and should
  be treated as externally leased developer access.
- Termux:Boot, wake locks, full desktop environments, audio servers, remote
  shell services, graphics acceleration, and LAN-visible VNC all require
  separate gates.

## Termux:X11 Notes

Start with the smallest visible X11 client before trying a full desktop. Record
the actual operator interaction needed to focus or move the pointer; on Quest,
panel focus can behave differently from a desktop mouse hover.

Basic terminal typing can work, but display geometry and text-heavy layouts
need their own validation. Do not promote a text editor or full desktop recipe
until the panel size, input focus, keyboard behavior, and cleanup path are
repeatable.

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
- capture the evidence needed;
- stop the VNC server;
- remove the ADB forward;
- verify that no listener remains.

If a VNC server fails on Android shared-memory permissions, retry with an
explicit no-shared-memory mode and record the exact flags. VNC mirrors the X
display; it does not fix headset-side panel geometry.

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

