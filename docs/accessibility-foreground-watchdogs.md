# Accessibility Foreground Watchdogs On Quest

Android Accessibility can provide a low-latency, privacy-minimized signal for
top-level Quest window and package changes. This is useful for an attended
foreground watchdog that brings a configured app forward again after Meta
Home, a system panel, or another app replaces it.

This is not lock-task mode, HOME ownership, device-owner policy, or a
tamper-resistant kiosk. Meta system UI may appear briefly, Horizon behavior can
change between releases, and an operator can disable or force-stop an ordinary
app. Use a vendor-supported managed-device route when those limitations are
not acceptable.

## Accessibility Versus Usage Access

| Requirement | Accessibility | Usage Access |
| --- | --- | --- |
| Foreground/window change latency | Event driven | Polls usage history |
| Meta panels and overlays | Often visible as windows | May be absent while the immersive app remains logically resumed |
| UI content access | Can be disabled | Not available |
| Background activity launch | Possible for an enabled service; verify each OS build | Normally needs a separate allowed launch surface |
| Physical HOME key interception | Not established | Not available |

Use Accessibility as the primary signal only when its policy and setup cost are
acceptable. Keep Usage Access as a coarse diagnostic fallback, not as evidence
that a Meta overlay is visibly covering the app.

## Privacy-Minimized Service Shape

Subscribe only to the window events needed by the decision engine:

```xml
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowsChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:canRetrieveWindowContent="false"
    android:isAccessibilityTool="false"
    android:notificationTimeout="0" />
```

The service declaration still requires
`android.permission.BIND_ACCESSIBILITY_SERVICE` and the normal
`android.accessibilityservice.AccessibilityService` intent filter.

Do not call `getRootInActiveWindow()`, inspect `event.source`, read node text,
identify controls, click buttons, or traverse another app's UI. Log only the
event type, package/class classification, decision, and bounded timing needed
for validation.

`notificationTimeout="0"` requests immediate delivery, but it does not make
the service a hardware-key listener or bypass Horizon scheduling.

## Enablement Through ADB

Quest builds may not expose the standard Accessibility settings page. For a
development headset, an already authorized ADB shell can enable the service as
a one-time setup operation.

Read the current state first:

```powershell
adb -s <serial> shell settings get secure enabled_accessibility_services
adb -s <serial> shell settings get secure accessibility_enabled
adb -s <serial> shell dumpsys accessibility
```

Then merge `<package>/<service>` into the existing colon-separated component
list and write the merged value:

```powershell
adb -s <serial> shell settings put secure enabled_accessibility_services <merged-components>
adb -s <serial> shell settings put secure accessibility_enabled 1
adb -s <serial> shell dumpsys accessibility
```

Never replace the component list blindly: another enabled Accessibility
service may already be present. Preserve before/after readback, use an exact
serial, and treat disablement or restoration as a separate explicit operator
action. Do not present this developer setup as a distributable consumer flow.

## Foreground Decision Model

Keep signal classification, escape counting, and recovery scheduling separate.
A robust model is:

1. Record that the configured target has been observed or that Android
   accepted a recovery launch for it.
2. Classify exact known Meta Home entry classes separately from generic
   Meta-shell package changes.
3. Group the burst of exact events from one Home action into one invocation.
4. Count only distinct invocations inside the configured escape window.
5. Allow late generic shell events from the same invocation to request another
   recovery without incrementing the escape counter.
6. Cancel a pending recovery when the target is observed again.
7. On the escape threshold, disarm before launching the configured return
   component.

An attended Quest trace found `1.2 s` a useful starting debounce for exact Home
signals and three invocations inside five seconds a usable escape gesture.
These are calibration values, not platform constants. Record the tested
Horizon build and retune when class/event timing changes.

The distinction in step 5 matters. Horizon can complete opening App Library or
another shell window after an immediate target launch. Ignoring that late event
can leave Home visible; counting it can make one press look like two or three.
Refocus and escape-counting are different decisions.

Some immersive activities resume without a fresh target-package
Accessibility event. After Android accepts a recovery launch, the decision
engine may mark the target as provisionally recovered and apply a short settle
window. Preserve later target/window evidence when it is available.

## Meta Home Diagnostics

On one Horizon family, top-level Accessibility events exposed App Library's
Navigator activity and VR shell Home/focus-placeholder activities. Treat exact
package and class names as version-specific diagnostic policy, not a public
Android contract.

This internal relay can exercise a synthetic Home transition on compatible
builds:

```powershell
adb -s <serial> shell am start `
  -a com.oculus.vrshell.intent.action.QUIT_TO_HOME `
  -n com.oculus.vrshell/.intents.AndroidIntentsRelayActivity
```

Use it only in a bounded lab harness. It can finish opening Home after the
watchdog's first recovery request, so wait for the target's actual focused
window before continuing.

Neither that relay nor `adb shell input keyevent HOME` proves physical Meta
button parity. A current attended trace did not expose the physical Home press
through `AccessibilityService.onKeyEvent()`. Keep a real-button witness as a
separate validation row.

## Background Launch Boundary

An enabled Accessibility service may be able to call `startActivity()` from
the background because Android binds it with background-start privileges. On
an attended Horizon build the launch succeeded while ActivityTaskManager also
printed a background-activity-launch hardening diagnostic.

Treat that as an observed build behavior, not a permanent exemption:

- launch an explicit exported activity;
- use the target's real launch action, categories, data, and MIME type;
- keep package visibility narrow;
- capture focused-window evidence after the request;
- scan for blocked background-launch diagnostics;
- revalidate after Horizon updates.

Do not add `SYSTEM_ALERT_WINDOW` merely to hide a failed design. If the target
cannot be foregrounded through an allowed route, report the limitation.

## Spatial Activity Return And Resource Recovery

Repeated background/foreground cycles can leave a long-running immersive or
Spatial activity with stale native, graphics, or panel state. A WebView panel
may remain visible even when native panel layers return blank, so one visible
panel is not sufficient recovery evidence.

When returning to a multi-panel hub, prefer an explicit return action:

```text
watchdog disarms
  -> explicit return action reaches the existing hub
  -> hub finishes and removes its stale task
  -> short bounded teardown delay
  -> fresh MAIN task starts with CLEAR_TASK
  -> hub reports fresh scene and panel-layer readiness
```

A `500 ms` delay was sufficient in one attended Spatial SDK validation to keep
old teardown from overlapping new scene creation. Treat this as a measured
starting point. Acceptance should require fresh panel/runtime markers, focused
Hub state, bounded memory readback, and zero package fatals—not only an
ActivityManager start result.

## Evidence Discipline

The Quest log buffer may discard early service-connect and arm markers during
a verbose spatial relaunch. Preserve evidence as stage snapshots or run a
streaming, harness-owned logcat window. Do not require every early token to
remain in a final `logcat -d` dump.

For each run, record:

- provider and exact serial;
- Horizon/Android build and PTC state;
- Accessibility configuration readback;
- target and return component shape using public placeholders;
- each distinct Home invocation and associated event burst;
- recovery request and actual focused-window result;
- escape/disarm result;
- fresh scene/panel readiness after return;
- package fatals, background-launch diagnostics, and memory summary;
- final armed state and cleanup.

Keep raw class/package traces, device serials, private app identities, logs,
screenshots, and generated APKs in private evidence. Publish only sanitized
behavioral findings and placeholder command shapes.
