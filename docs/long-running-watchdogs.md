# Long-Running Watchdogs And Device-Side Helpers

Long Quest workflows can fail for reasons unrelated to the app under test:
display sleep, virtual proximity state changes, mount state changes, foreground
loss, headset prompts, or camera provider stalls. A watchdog can keep a lab run
stable, but it is a device-setting intervention and must be explicit.

## Boundary

There are three different identities:

```text
external ADB host
  PC, phone, CI worker, or developer terminal authorized by the user

device-side ADB-launched helper
  pushed to /data/local/tmp and started by adb shell, often with app_process
  runs as Android shell for that ADB session

installed app or broker
  normal Android app UID
  can receive helper status but does not become shell
```

The installed app cannot start an ADB helper by itself. The helper exists only
because an authorized external ADB host pushed and launched it.

## Why This Matters

For long camera, OpenXR, capture, or screenshot runs, the headset can drift into
a state where ADB still responds and an app can launch, but camera frames or
display evidence are not valid. The most useful watchdogs distinguish:

- display awake versus asleep;
- virtual proximity close versus open/disabled;
- foreground app versus Meta shell/panel;
- broker/service reachable versus visible app ready;
- OpenXR frame loop alive versus camera frames advancing.

Do not collapse those into one "device ready" flag.

## Proximity And Awake Watchdog

A public-safe watchdog pattern:

1. Read `dumpsys vrpowermanager` or a provider-equivalent health report.
2. If the desired virtual proximity hold is enabled and readback is not
   `CLOSE`, reapply the virtual close signal.
3. If stay-awake enforcement is enabled and `dumpsys power` shows the headset
   left awake/display-on state, reapply stay-awake and send wakeup.
4. Report counters and last readbacks to the app, broker, or artifact bundle.
5. Stop the watchdog before intentionally restoring normal wear-sensor
   behavior.

Representative ADB operations used by helper implementations:

```powershell
adb -s <serial> shell dumpsys vrpowermanager
adb -s <serial> shell dumpsys power
adb -s <serial> shell svc power stayon true
adb -s <serial> shell input keyevent KEYCODE_WAKEUP
```

The virtual proximity broadcast is platform-specific and should live in a
helper implementation, not in generic public docs as a casual one-liner.

## Stop And Restore

Stopping the watchdog and restoring normal headset behavior are separate
actions:

```text
stop helper/watchdog
  -> helper stops reapplying proximity or awake state

restore normal proximity/power behavior
  -> operator or provider explicitly returns device to normal mode
```

Never run "restore normal" automatically at the end of a generic validation
script unless the run explicitly owns that state. A different operator or
agent may have intentionally started a long-running watchdog.

## Idempotence

A good watchdog is idempotent:

- It reads first.
- It reapplies only when readback is not the desired state.
- It increments repair counters only when it changes state.
- It reports current state even when no repair was needed.
- It does not spam power/proximity commands on every poll.

This lets an external watchdog and a device-side helper coexist. If either
repairs the state, the other observes the desired state on the next poll.

## Focus Guardian

A focus guardian is separate from an awake/proximity watchdog. It can:

- poll current foreground package/window;
- observe broker or app control state;
- launch a target app or return to a broker/launcher panel after focus loss;
- force-stop a bounded test target after a preview window expires.

It cannot:

- intercept protected system buttons;
- guarantee OpenXR input focus;
- prove visual success;
- bypass headset prompts or permission dialogs.

Foreground recovery should always be paired with a visual or app-side readiness
signal before a screenshot or metric sample is accepted.

## Evidence To Record

For any run using a watchdog, record:

- helper kind and version;
- host provider that started it;
- start time, stop time, and whether it was still running at handoff;
- proximity readback and repair count;
- wake/display readback and repair count;
- foreground before/after;
- app/broker status if available;
- whether normal proximity/power behavior was restored.

## Caution

Watchdogs are crucial for long unattended workflows, but they are also a source
of false confidence. A headset can be awake and foregrounded while raw camera
delivery is stalled, OpenXR view pose is invalid, MediaProjection is waiting
for consent, or the render loop is showing only a fallback clear. Keep
watchdog readiness separate from app and camera readiness.
