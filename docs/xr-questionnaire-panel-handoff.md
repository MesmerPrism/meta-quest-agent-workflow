# XR Questionnaire Panel Handoff

This playbook describes a Quest workflow for testing a reusable 2D
questionnaire panel that can be opened by any cooperating foreground XR app,
then return to that same XR app without using the Meta menu, force-stopping
packages, or making ADB part of the product path.

Status: design and validation workflow. Treat same-package hybrid apps as a
reference baseline, not as a requirement for the general feature.

For the generic cross-app IPC rules behind this example, including manifest
snippets, PendingIntent pitfalls, URI grant scope, lifecycle recovery, and the
security test matrix, see `docs/cross-app-content-uri-ipc.md`.

## Target Behavior

The intended product path is:

```text
foreground XR app
  -> app-owned launch command
  -> separate 2D questionnaire panel foregrounded
  -> questionnaire receives normal Quest panel input
  -> questionnaire writes final result JSON to caller-owned content URI
  -> questionnaire invokes caller-provided return route
  -> same XR app instance returns to foreground/focus
```

The questionnaire app and XR app can be separate APKs. The important
requirement is cooperation: the XR app launches the panel while the XR app is
already foregrounded, and the questionnaire app uses a caller-supplied return
route rather than guessing which XR app to foreground later.

The foreground switch and the answer transport are separate contracts. The
recommended result channel is a caller-owned `content://` URI backed by the XR
app's private app storage and exposed through a narrow `FileProvider` or custom
`ContentProvider`. The `PendingIntent` return route should signal completion;
the result JSON should carry the status and answers.

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
- a per-session request id and random nonce;
- an optional questionnaire/schema id;
- small request metadata or JSON inline, or a request URI when the payload is
  too large for launch extras;
- a caller-owned result `content://` URI, usually from an XR-owned
  `FileProvider` or custom provider;
- a return route created by the XR app.

The return route should usually be a `PendingIntent`. For result ingestion,
prefer a broadcast `PendingIntent` to a caller-owned private receiver; this
works as a completion signal without trying to start UI from the background.
Use an activity-return `PendingIntent` only when the questionnaire must
actively bring the XR activity forward. That path needs Android 14/15
background-activity-launch validation and Logcat checks for blocked launches.

For the simple case, keep the request JSON in extras and grant only write access
to the result URI. The result URI should be backed by an app-private per-session
file such as `questionnaire/results/<opaque-request-id>/result.json`, not by
public shared storage.

```kotlin
val completionIntent = Intent(this, QuestionnaireReturnReceiver::class.java).apply {
    action = "org.example.quest.action.QUESTIONNAIRE_COMPLETE"
    data = Uri.parse("app://${packageName}/questionnaire-return/$requestId")
    putExtra("request_id", requestId)
}

val returnToXr = PendingIntent.getBroadcast(
    this,
    requestId.hashCode(),
    completionIntent,
    PendingIntent.FLAG_CANCEL_CURRENT or
        PendingIntent.FLAG_ONE_SHOT or
        PendingIntent.FLAG_IMMUTABLE
)

val resultUri = FileProvider.getUriForFile(
    this,
    "${packageName}.questionnaire.results",
    resultFile
)

val questionnaireIntent =
    Intent("org.example.quest.action.START_QUESTIONNAIRE").apply {
        setComponent(
            ComponentName(
                "org.example.quest.questionnaire",
                "org.example.quest.questionnaire.QuestionnaireActivity"
            )
        )
        addCategory(Intent.CATEGORY_DEFAULT)
        setDataAndType(
            resultUri,
            "application/vnd.example.questionnaire-result+json"
        )
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        putExtra("request_id", requestId)
        putExtra("request_nonce", nonce)
        putExtra("session_id", sessionId)
        putExtra("request_json", requestJson)
        putExtra("result_uri", resultUri)
        putExtra("return_to_xr", returnToXr)
    }

startActivity(questionnaireIntent)
```

The XR activity should use launch flags or manifest launch mode choices that
resume the existing immersive instance instead of creating a duplicate task.
It should persist the request id, nonce, expected result URI, and enough session
state to recover if the callback cold-starts the XR process.

If an active return-to-activity callback is required, create a separate
explicit activity `PendingIntent` with `FLAG_ONE_SHOT | FLAG_IMMUTABLE`, use a
unique request code or intent `data` URI, and validate the route on target
Android/Horizon OS versions for background activity launch restrictions.

Android 11+ package visibility applies when the XR app resolves, version-checks,
or signing-checks the questionnaire package. Declare the narrowest `<queries>`
entry that covers the package, launch intent, or provider authority. Android
12+ requires `android:exported` on intent-filter components and explicit
PendingIntent mutability. On Quest, do not use `QUERY_ALL_PACKAGES`,
`SYSTEM_ALERT_WINDOW`, broad external-storage permissions, or overlay tricks
for this workflow.

## Result URI Contract

Use a caller-owned result URI by default:

```text
XR app private storage
  -> per-request result file
  -> FileProvider/custom provider exposes only that file as content://
  -> questionnaire receives write grant
  -> XR app reads and validates result after callback or resume
```

For `FileProvider`, use a narrow path whitelist, `exported=false`, and
`grantUriPermissions=true`. Prefer internal or app-specific private backing
storage. Do not use public `/sdcard` folders, MediaStore, broad provider roots,
or `file://` URIs for participant answers.

Recommended result envelope:

```json
{
  "schema": "org.example.quest.questionnaire.result.v1",
  "request_id": "opaque-request-id",
  "nonce": "random-per-request-nonce",
  "status": "completed",
  "questionnaire": {
    "id": "presence-v2",
    "version": 2
  },
  "answers": {},
  "started_at": "2026-06-10T12:00:00Z",
  "submitted_at": "2026-06-10T12:03:00Z"
}
```

The XR app should treat the JSON as untrusted input: verify schema, request id,
nonce, status, questionnaire id/version, and answer shape before ingesting it.
Avoid logging full answer payloads.

URI grant details matter. Android grant flags apply to Intent data and
`ClipData`; if several URIs are placed in one Intent with both read and write
flags, the receiving app can receive broader access than intended. For larger
payloads, use one of these instead:

- inline launch extras plus one write-only result URI;
- manual per-URI `grantUriPermission` calls and explicit revocation after
  callback or timeout;
- a custom provider that enforces read/write mode per path, such as
  `/session/{id}/request` read-only and `/session/{id}/result` write-only.

## Return Path

The questionnaire panel should write the final JSON first, close the stream,
send the supplied route, and close only its own visible activity:

```kotlin
fun returnToXrAndClose(activity: Activity) {
    activity.contentResolver.openOutputStream(resultUri, "wt").use { out ->
        out!!.write(resultJson.toByteArray(Charsets.UTF_8))
    }
    val returnToXr =
        activity.intent.getParcelableExtra<PendingIntent>("return_to_xr")
    returnToXr?.send()
    activity.finish()
}
```

If using an activity-return `PendingIntent` instead of the broadcast completion
route, the questionnaire sender side should pass Android background activity
launch options required by the target API level and record Logcat evidence that
the launch was not blocked.

Do not use `am force-stop`, package killing, public file drops, Termux, or an
ADB relaunch as the normal return path or answer channel. If the questionnaire
app needs work to continue after its panel closes, put that work behind an
explicit service, sidecar, or backend result channel with its own permission
model. Do not treat a closed Activity as durable runtime state.

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

Persist pending questionnaire state before starting the panel. The XR app
should check pending result files on callback, on resume, and cold start. The
questionnaire should write on explicit submit rather than relying on
`onStop()` or `onDestroy()`. Spatial SDK immersive activities should declare
the required `android:configChanges` values for the target Horizon OS so a
configuration change does not destroy the 3D scene during handoff recovery.

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
4. Questionnaire writes result JSON to the caller-owned result URI before
   returning.
5. Questionnaire return control sends the supplied return route and closes only
   the panel activity.
6. Same XR app instance regains foreground/focus and validates schema,
   request id, nonce, status, and answer shape.
7. Negative control: background service or hidden sidecar tries to foreground
   the panel and is rejected or routed through a visible/operator path.
8. ADB fallback pass, explicitly labeled, for recovery or comparison only.
9. Android 11+ visibility pass: removing the intended `<queries>` entry breaks
   optional discovery/version checks, while explicit launch still behaves as
   documented for the chosen contract.
10. Android 12+ manifest pass: all intent-filter components declare
    `android:exported`, and every PendingIntent declares mutability.
11. Android 14/15+ return pass: broadcast completion works without UI start;
    activity-return, if used, is checked for background-activity-launch blocks.
12. Grant cleanup and duplicate-callback pass: manual URI grants are revoked
    after completion/timeout, and duplicate callbacks or second sends are
    idempotent.

Record for each run:

- device model family and Horizon OS version;
- caller package/activity and questionnaire package/activity, sanitized before
  publishing;
- foreground package/activity before launch, during panel focus, and after
  return;
- OpenXR session-state changes for the XR app;
- process liveness for both packages;
- result-channel shape, URI grant mode, and whether a caller-owned result URI
  was used;
- result validation status without publishing answer payloads;
- whether a protected prompt, controller requirement, or Meta system panel
  appeared;
- whether the product path used ADB, force-stop, package killing, or Meta menu
  navigation;
- whether Termux, shared public storage, MediaStore, or raw file paths were
  avoided in the product result channel.
- whether `QUERY_ALL_PACKAGES`, `SYSTEM_ALERT_WINDOW`, broad storage
  permissions, or overlay-style return flows were avoided.
- backup/data-extraction policy for transient result directories when answer
  data is sensitive.

Keep raw screenshots, logcat, serials, private package identities, generated
APKs, local paths, and pairing material out of public artifacts.

## Related Workflow Docs

- `docs/apk-install-launch.md`
- `docs/artifact-and-evidence-discipline.md`
- `docs/cross-app-content-uri-ipc.md`
- `docs/openxr-tracking-boundary.md`
- `docs/quest-signal-patterns.md`
- `docs/termux-linux-sidecars.md`
