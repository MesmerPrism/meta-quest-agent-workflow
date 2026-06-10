# Cross-App Content URI IPC

This playbook describes a reusable Quest/Android pattern for one app to launch
another app, hand over a bounded request, receive a structured result, and
recover cleanly after lifecycle interruptions. The questionnaire panel workflow
is the main example, but the contract applies to any cooperating cross-package
utility app.

## Default Protocol

Keep foreground switching and data transport separate:

```text
caller app
  -> creates session id, request id, nonce, and private result file
  -> exposes only that file as a temporary content:// URI
  -> persists pending-session state before launch
  -> starts explicit callee activity with small request metadata

callee app
  -> treats request input as untrusted
  -> renders its normal 2D panel or utility UI
  -> writes final JSON to the granted result URI on explicit submit
  -> closes the stream
  -> sends the caller-provided completion PendingIntent
  -> finishes only its own visible activity

caller app
  -> receives callback, resumes, or cold-starts later
  -> reads its own result URI
  -> validates schema, request id, nonce, status, and answer shape
  -> revokes manual grants when used and cleans up by policy
```

For small requests, pass request metadata or JSON in extras and include only
one write-only result URI. For larger payloads, prefer a custom
`ContentProvider` that enforces read/write mode per path, or use explicit
per-URI grants and revocation. Prefer an explicit package/component for the
callee launch, especially when the result URI is carried as the Intent data
URI for grant purposes.

## Result URI Contract

The caller owns the result file and grants the callee temporary access.

Use this default shape:

```text
caller private storage
  -> session/request scoped result.json
  -> narrow FileProvider or custom ContentProvider
  -> temporary write grant to the callee
  -> caller reads and validates after completion
```

`FileProvider` is enough for the simple case when it uses:

- `android:exported="false"`;
- `android:grantUriPermissions="true"`;
- a narrow path whitelist for the result directory;
- app-private or app-specific backing storage;
- no broad `external-path`, public `/sdcard`, MediaStore, or `file://` route.

Recommended result envelope:

```json
{
  "schema": "org.example.crossapp.result.v1",
  "request_id": "opaque-request-id",
  "nonce": "random-per-request-nonce",
  "status": "completed",
  "producer": {
    "id": "questionnaire",
    "version": 1
  },
  "answers": {},
  "started_at": "2026-06-10T12:00:00Z",
  "submitted_at": "2026-06-10T12:03:00Z"
}
```

Treat result JSON as untrusted input. Validate the schema/version, request id,
nonce, status, producer id/version, timestamps, and payload shape before
ingesting. Do not put participant answers in filenames, logs, notifications,
PendingIntent extras, or crash breadcrumbs.

## PendingIntent Return Routes

Use a `PendingIntent` as a completion signal, not as the data container.

Default route:

- `PendingIntent.getBroadcast()` to a caller-owned receiver that marks the
  pending session complete and reads the caller-owned result URI.
- Explicit base intent, private receiver, unique request code or unique intent
  `data` URI.
- `FLAG_IMMUTABLE | FLAG_ONE_SHOT` by default.
- `FLAG_CANCEL_CURRENT` or unique request codes when replacing pending
  sessions.

Use an activity-return `PendingIntent` only when the callee must actively bring
the caller's activity forward. For that route, test Android 14/15 background
activity launch behavior and keep the return explicit and one-shot. Blocked
activity launches can show up only in Logcat, so look for background activity
launch denial messages during validation.

Do not authenticate the callee solely from PendingIntent provenance. The
creator package identifies who created the PendingIntent, not who later handed
it around. Use explicit package/component names, a request id, a random nonce,
and result validation instead.

## URI Grant Shape

Intent grant flags are broad across the Intent data URI and `ClipData`. If a
read-only request URI and write-only result URI are placed in the same
`ClipData` while both read and write flags are set, the callee can receive
broader access than intended.

Safer defaults:

- inline small request JSON in extras plus one write-only result URI;
- manual `grantUriPermission()` calls per URI/mode with explicit revocation;
- a custom provider that enforces `/request` read-only and `/result`
  write-only internally.

Revoke manual grants after completion, timeout, cancellation, or replacement.
If relying on automatic Intent grants, still remove or expire transient result
files according to the caller's retention policy.

## Manifest Checklist

Caller-owned `FileProvider`:

```xml
<provider
    android:name=".ResultFileProvider"
    android:authorities="${applicationId}.crossapp.results"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/crossapp_result_paths" />
</provider>
```

Caller package visibility for Android 11/API 30 and newer:

```xml
<queries>
    <package android:name="org.example.quest.questionnaire" />

    <intent>
        <action android:name="org.example.quest.action.START_QUESTIONNAIRE" />
        <data android:mimeType="application/vnd.example.questionnaire-request+json" />
    </intent>

    <provider android:authorities="org.example.quest.questionnaire.provider" />
</queries>
```

Use the narrowest `<queries>` declaration that supports install checks,
version checks, intent resolution, signing checks, or provider checks. Do not
use `QUERY_ALL_PACKAGES` for this workflow.

Callee launch activity:

```xml
<activity
    android:name=".QuestionnaireActivity"
    android:exported="true"
    android:resizeableActivity="true">
    <intent-filter>
        <action android:name="org.example.quest.action.START_QUESTIONNAIRE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="application/vnd.example.questionnaire-request+json" />
    </intent-filter>
</activity>
```

Caller completion receiver:

```xml
<receiver
    android:name=".QuestionnaireReturnReceiver"
    android:exported="false" />
```

Android 12/API 31 and newer require explicit `android:exported` on components
with intent filters and explicit PendingIntent mutability flags.

For Spatial SDK immersive activities, declare the required `configChanges`
values so Horizon OS configuration changes do not tear down the 3D scene:

```xml
<activity
    android:name=".ImmersiveActivity"
    android:configChanges="screenSize|screenLayout|orientation|keyboardHidden|keyboard|navigation|uiMode"
    android:launchMode="singleTask"
    android:exported="true" />
```

2D panel activities can use a smaller set when recreation is acceptable.

## Quest Permission Policy

Keep the cross-app result channel inside normal Android IPC:

- no `QUERY_ALL_PACKAGES`;
- no broad external storage permissions for questionnaire exchange;
- no `MANAGE_EXTERNAL_STORAGE`, `MANAGE_DOCUMENTS`, or `MANAGE_MEDIA`;
- no `SYSTEM_ALERT_WINDOW` or overlay-based return flow;
- no Termux file drop, shared public storage, force-stop, package killing, or
  Meta menu navigation as the product path.

Use app-scoped storage plus temporary `content://` grants.

## Lifecycle And Recovery

Persist session state before launching the callee. Store at least:

- session id;
- request id;
- nonce;
- expected result URI;
- expected callee package/component;
- schema or questionnaire id/version;
- created-at and timeout deadline.

The callee should write the result during explicit submit, not in `onDestroy()`.
The caller should check pending result files on callback, `onResume`, and cold
start. A duplicate callback or second result write must be idempotent.

Quest/Spatial SDK callers should treat `onVRPause`, `onVRReady`,
`onHMDMounted`, and `onHMDUnmounted` as meaningful state transitions. Do not
interpret a lost OpenXR `FOCUSED` state during a panel handoff as failure by
itself; validate that the session stays recoverable and returns to focus when
the handoff completes.

If questionnaire results contain sensitive or participant data, exclude
transient session directories from backup/data-extraction rules unless
retention is intentional and documented.

## Same-App Or Split-App Decision

Use same-app panels when the questionnaire is tightly coupled to one XR app and
can share lifecycle/state through normal in-process mechanisms.

Use the split-app content-URI contract when the questionnaire is a reusable
utility for multiple caller apps, must be independently updated, or should have
its own package boundary. Do not use global Activity references as the split
app communication layer.

## Validation Matrix

| Area | Test |
| --- | --- |
| URI grant | Callee can write the result URI and cannot open unrelated caller files. |
| Grant cleanup | After completion, timeout, or manual revoke, callee cannot reopen the result URI. |
| ClipData mistake | Request and result URIs are not over-granted when multiple URIs are present. |
| PendingIntent identity | Callback uses explicit intent, one-shot behavior, and unique request identity. |
| Callback duplication | Duplicate callback/result delivery is ignored or handled idempotently. |
| Process death | Caller death after launch still recovers result on callback, resume, or cold start. |
| Callee death | Callee death mid-form leaves the caller session pending, canceled, or relaunchable. |
| Android 11+ visibility | Caller resolves or validates the callee only through intended `<queries>`. |
| Android 12+ manifest | Components with intent filters declare `android:exported`; PendingIntents declare mutability. |
| Android 14/15+ return | Broadcast flow works without UI start; activity-return flow is tested for background-launch blocks. |
| Quest/Horizon | Physical headset pass covers panel focus, back behavior, app switching, HMD mount/unmount, and Spatial lifecycle. |
| Privacy | Result data is absent from logs, filenames, public storage, notifications, and PendingIntent extras. |

## Reference Links

- Android content provider basics: https://developer.android.com/guide/topics/providers/content-provider-basics
- Android secure file sharing: https://developer.android.com/training/secure-file-sharing
- AndroidX FileProvider reference: https://developer.android.com/reference/kotlin/androidx/core/content/FileProvider
- Android Intent and ClipData URI grants: https://developer.android.com/reference/android/content/Intent
- Android Context URI grants: https://developer.android.com/reference/android/content/Context
- Android PendingIntent reference: https://developer.android.com/reference/android/app/PendingIntent
- Android background activity launch rules: https://developer.android.com/guide/components/activities/background-starts
- Android package visibility: https://developer.android.com/training/package-visibility
- Android 12 behavior changes: https://developer.android.com/about/versions/12/behavior-changes-12
- Android app-specific storage: https://developer.android.com/training/data-storage/app-specific
- Meta unsupported permissions: https://developers.meta.com/horizon/documentation/android-apps/unsupported-permissions/
- Meta Android apps on Horizon OS: https://developers.meta.com/horizon/documentation/android-apps/horizon-os-apps/
- Meta Spatial SDK lifecycle: https://developers.meta.com/horizon/documentation/spatial-sdk/spatial-sdk-activity-lifecycle/
- Meta Spatial SDK 2D panel communication: https://developers.meta.com/horizon/documentation/spatial-sdk/spatial-sdk-2dpanel-communication/
