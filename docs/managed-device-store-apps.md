# Managed Device Store Apps And Paid Entitlements

Use this guide when validating Meta Horizon Store apps on an
organization-managed Quest. Managed-device mode, Android user/profile, Store
policy, and account entitlement are separate gates.

## Identify The Device Mode First

| Mode | Consumer Horizon Store | Paid consumer apps |
| --- | --- | --- |
| Individual Mode | Available unless the administrator disables it | Purchased and installed in-headset for the signed-in managed or allowed personal account |
| Shared Mode | Not available | Not available through the consumer Store; use the managed **Discover Apps** catalog or another organization-approved distribution route |

The managed catalog and consumer Store are different products. The managed
catalog contains an administrator-distributable subset and must not be treated
as proof that every consumer app, paid title, or entitlement is available.
Revalidate this policy before a deployment because Meta can change catalog and
mode capabilities independently of Horizon OS.

## Account And Purchase Boundary

In Individual Mode, a purchase belongs to the account that completes it. A
managed Meta account can be asked to configure its own Store PIN and payment
method; the organization's administrator payment method is not an implied
purchase authority. An allowed personal account has a separate library and
data. Install and test the title under the same Android user/profile that will
run the launcher or kiosk.

Treat every paid-app action as attended financial consent:

- automation may inspect Store availability and open its public launcher;
- the wearer chooses the title and price;
- the wearer confirms **Buy**, Store PIN, payment, and any terms;
- automation resumes only after the wearer reports that installation is
  complete.

Never automate a purchase, enter payment or Store-PIN data, extract a paid APK,
or relabel sideloading as Store entitlement. Publisher terms may separately
restrict organizational or commercial use even when the account owns the app.

## Read-Only Store Preflight

Keep raw package and device-policy dumps private. Check only what the run needs
and avoid account databases, account identifiers, email addresses, or payment
state.

```powershell
$storePackage = 'com.oculus.store'
adb -s <serial> shell cmd package resolve-activity --brief `
  -a android.intent.action.MAIN `
  -c android.intent.category.LAUNCHER `
  $storePackage
adb -s <serial> shell dumpsys package $storePackage
adb -s <serial> shell dumpsys user 0
```

Require an installed, enabled, non-hidden, non-suspended Store package, a
resolved launcher activity, and no effective policy restriction that blocks
the Store. Package and component names are observations, not stable contracts;
record what the device resolves rather than embedding it into a product.

Before opening the Store, record the foreground app and disarm any lab
foreground watchdog that could immediately restore another package. With
operator approval, launch the resolved component:

```powershell
adb -s <serial> shell am start -W -n <resolved-store-component>
```

`Status: ok` plus foreground readback proves only that the Store Activity ran.
It does not prove account login, purchase authority, entitlement, installation,
or successful application launch.

## Attended Paid-App Validation

1. The wearer buys a title or installs one already owned by the current
   account.
2. After the wearer reports completion, identify only the expected package and
   record its installer attribution.
3. Resolve its public launcher instead of assuming an Activity name.
4. Launch it normally and require foreground plus app/OpenXR readiness and zero
   bounded package fatals.
5. If a launcher or soft watchdog is under test, exercise that path separately.
   Store installation is not kiosk validation.

```powershell
adb -s <serial> shell pm list packages -i
adb -s <serial> shell cmd package resolve-activity --brief <package>
adb -s <serial> shell am start -W -n <resolved-app-component>
```

Installer attribution is supporting evidence, not entitlement proof. Paid apps
can still perform their own online entitlement checks at launch.

## Launcher Lifecycle Boundary

Switching away from a Store app normally stops its Activity and backgrounds
its task. Android may keep the process resident as a cache and reclaim it under
memory pressure. A background OpenXR session should stop submitting frames as
it transitions through `STOPPING` to `IDLE`, but an app-owned service, audio,
download, or faulty worker can remain active.

A launcher may use task flags to refresh a selected app, but a fresh task is
not a guaranteed fresh Linux process. `FLAG_ACTIVITY_CLEAR_TASK` can destroy
and recreate Activities while Android keeps the process and process-wide state.
Conversely, `FLAG_ACTIVITY_REORDER_TO_FRONT` is appropriate when a watchdog
intends to resume the existing session.

An ordinary third-party launcher cannot reliably terminate arbitrary Store
apps. On Android 14 and later, `killBackgroundProcesses()` is limited to the
caller's own application. Do not add shell, device-owner, or force-stop
authority merely to clean normal cached tasks. For a cold-process validation,
an explicitly authorized ADB harness may `am force-stop` only the named target;
that remains developer workflow, not product behavior.

## Current References

- Meta managed-account help: <https://www.facebook.com/help/1093311068161696/>
- Meta Shared Mode app assignment: <https://www.facebook.com/help/929282808591864/>
- Current managed-mode and paid-purchase field guidance: <https://help.managexr.com/en/articles/10509502-meta-horizon-device-modes>
- Managed versus consumer Store comparison: <https://help.managexr.com/en/articles/13199177-meta-horizon-managed-app-store-integration>
- Android activity lifecycle: <https://developer.android.com/guide/components/activities/activity-lifecycle>
- Android process lifecycle: <https://developer.android.com/guide/components/activities/process-lifecycle>
- Android task and back-stack behavior: <https://developer.android.com/guide/components/activities/tasks-and-back-stack>
- OpenXR session lifecycle: <https://registry.khronos.org/OpenXR/specs/1.0-khr/html/xrspec.html#session-lifecycle>
