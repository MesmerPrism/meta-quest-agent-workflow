# Shell Helper Boundary

A shell helper is an ADB-launched device-side process, often started from
`/data/local/tmp` with Android's `app_process`. It is a developer tool. It is
not a normal installed app permission, and a public APK cannot start it by
itself without an authorized ADB host.

## Typical Launch Shape

This is a template, not a universal command:

```powershell
adb -s <serial> push <helper-jar> /data/local/tmp/<helper>.jar
adb -s <serial> shell "CLASSPATH=/data/local/tmp/<helper>.jar app_process /system/bin <main-class> <args>"
```

Use a project-specific helper only when the operator has approved the shell
side effects.

## Good Uses

```text
foreground/package readback
safe launch guard
logcat streaming
dumpsys snapshots
bounded screenrecord capture
ADB-forwarded status endpoint
device-side proximity/watchdog loop
stay-awake reapply loop
```

## Watchdog Contract

For long unattended workflows, the helper can keep the headset in a useful
developer state by:

```text
observing virtual proximity state
reapplying the desired virtual proximity state only if drift is observed
observing wakefulness and display power state
reapplying KEYCODE_WAKEUP or stay-awake only if drift is observed
reporting reapply counts through a status endpoint
stopping through an explicit stop marker or operator command
```

The helper should be idempotent with an external host-side watchdog. If either
one repairs the state first, the other should observe success and avoid extra
changes.

## Restore Is Separate

Stopping the helper should stop future reapply actions. Restoring normal
wear-sensor or proximity behavior is a separate operator action because
different tests intentionally choose different final states. Retain authorized
development-device changes by default. Record prior values only if needed for
the effect or an explicitly temporary/owner-required restoration, not as an
exhaustive rollback snapshot.

Record:

```text
helper version or source
launch command
desired proximity/wake policy
duration
status endpoint snapshots
relevant power/vrpowermanager readback for the requested effect
final retained state and deltas
restore action and reason, only if required
```

## Boundary Language

Say:

```text
"ADB-launched shell helper kept the development headset awake."
```

Do not say:

```text
"The APK has shell privileges."
"The app bypasses headset permissions."
"This is a store-style capability."
```

