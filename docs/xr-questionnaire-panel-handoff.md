# XR Questionnaire Panel Handoff

This playbook describes a Quest workflow for testing a reusable 2D
questionnaire panel that can be opened by any cooperating foreground XR app,
then return to that same XR app without using the Meta menu, force-stopping
packages, or making ADB part of the product path.

Status: design and validation workflow. Treat same-package hybrid apps as a
reference baseline, not as a requirement for the general feature.

## Target Behavior

The intended product path is:

```text
foreground XR app
  -> app-owned launch command
  -> separate 2D questionnaire panel foregrounded
  -> questionnaire receives normal Quest panel input
  -> questionnaire invokes caller-provided return route
  -> same XR app instance returns to foreground/focus
```

The questionnaire app and XR app can be separate APKs. The important
requirement is cooperation: the XR app launches the panel while the XR app is
already foregrounded, and the questionnaire app uses a caller-supplied return
route rather than guessing which XR app to foreground later.

## App Contract

The questionnaire APK should expose an exported Quest 2D panel activity. A
minimal public example shape is:

```xml
<activity
    android:name=".QuestionnaireActivity"
    android:exported="true"
    android:resizeableActivity="true"
    android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize">
    <intent-filter>
        <action android:name="org.example.quest.action.START_QUESTIONNAIRE" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="com.oculus.intent.category.2D" />
    </intent-filter>
    <layout
        android:defaultHeight="720dp"
        android:defaultWidth="1080dp"
        android:minHeight="540dp"
        android:minWidth="720dp" />
</activity>
```

Add `android.intent.action.MAIN` plus `android.intent.category.LAUNCHER` if
the questionnaire should also be directly user-launchable. Add
`com.oculus.intent.category.OVERLAY_LAUNCHER` only after a headset validation
pass proves it gives the intended overlay behavior on the target Horizon OS
version.

The foreground XR app should launch the questionnaire with:

- a session id;
- an optional questionnaire/schema id;
- a result destination, such as a content provider, app-owned shared file,
  broker endpoint, local service endpoint, or backend session id;
- a return route created by the XR app.

The return route should usually be a `PendingIntent`. It preserves the exact
initiating activity and avoids a package-name lookup file as the primary
contract.

```kotlin
val returnIntent = Intent().apply {
    setComponent(ComponentName(packageName, VrActivity::class.java.name))
    action = Intent.ACTION_MAIN
    addCategory("com.oculus.intent.category.VR")
    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
}

val returnToXr = PendingIntent.getActivity(
    this,
    sessionId.hashCode(),
    returnIntent,
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)

val questionnaireIntent =
    Intent("org.example.quest.action.START_QUESTIONNAIRE").apply {
        setPackage("org.example.quest.questionnaire")
        addCategory(Intent.CATEGORY_DEFAULT)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        putExtra("session_id", sessionId)
        putExtra("return_to_xr", returnToXr)
    }

startActivity(questionnaireIntent)
```

The XR activity should use launch flags or manifest launch mode choices that
resume the existing immersive instance instead of creating a duplicate task.

## Return Path

The questionnaire panel should return by sending the supplied route and closing
only its own visible activity:

```kotlin
fun returnToXrAndClose(activity: Activity) {
    val returnToXr =
        activity.intent.getParcelableExtra<PendingIntent>("return_to_xr")
    returnToXr?.send()
    activity.finish()
}
```

Do not use `am force-stop`, package killing, or an ADB relaunch as the normal
return path. If the questionnaire app needs work to continue after its panel
closes, put that work behind an explicit service, sidecar, or backend result
channel. Do not treat a closed Activity as durable runtime state.

A configured return package/activity can be a fallback when a `PendingIntent`
is not available, but that route needs package visibility handling and clear
error reporting for missing packages, duplicate tasks, protected prompts, and
wrong-target returns.

## Focus Expectations

When the questionnaire panel is focused, the XR app should not assume it still
has XR input focus. In OpenXR terms, a successful run is expected to look like:

```text
XR app FOCUSED
questionnaire panel focused, XR app alive and possibly VISIBLE
same XR app FOCUSED again after panel close
```

Use OpenXR session-state logs, app-owned status, and foreground readback to
distinguish "alive but not focused" from "stopped" or "relaunched."

## ADB And Termux Boundary

ADB is useful for development installs, launches, foreground readback, logcat,
screenshots, and recovery. It should not be required for the product-path UX.

Classify runs separately:

- product path: XR app launches questionnaire and questionnaire returns through
  the caller-provided route;
- ADB fallback: `adb shell am start`, `input keyevent`, or explicit relaunch
  was used for setup or recovery;
- Termux fallback: an on-device Termux ADB client was used only after normal
  user-authorized WiFi ADB proved Android `shell` identity.

For Termux-side ADB, the shell gate is:

```sh
adb connect 127.0.0.1:5555
adb -s 127.0.0.1:5555 shell id
```

The pass condition is:

```text
uid=2000(shell)
```

Without that identity, do not treat Termux as app launch authority.

## Validation Matrix

Run the smallest matrix that answers the product question:

1. Same-package 2D panel and immersive activity, as a known reference baseline.
2. Separate questionnaire APK launched by a foreground XR app through the app
   contract above.
3. Questionnaire panel receives normal Quest input while the XR app stays
   alive.
4. Questionnaire return control sends the supplied return route and closes only
   the panel activity.
5. Same XR app instance regains foreground/focus.
6. Negative control: background service or hidden sidecar tries to foreground
   the panel and is rejected or routed through a visible/operator path.
7. ADB fallback pass, explicitly labeled, for recovery or comparison only.

Record for each run:

- device model family and Horizon OS version;
- caller package/activity and questionnaire package/activity, sanitized before
  publishing;
- foreground package/activity before launch, during panel focus, and after
  return;
- OpenXR session-state changes for the XR app;
- process liveness for both packages;
- whether a protected prompt, controller requirement, or Meta system panel
  appeared;
- whether the product path used ADB, force-stop, package killing, or Meta menu
  navigation.

Keep raw screenshots, logcat, serials, private package identities, generated
APKs, local paths, and pairing material out of public artifacts.

## Related Workflow Docs

- `docs/apk-install-launch.md`
- `docs/artifact-and-evidence-discipline.md`
- `docs/openxr-tracking-boundary.md`
- `docs/quest-signal-patterns.md`
- `docs/termux-linux-sidecars.md`
