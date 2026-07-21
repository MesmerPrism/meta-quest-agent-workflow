# Host-to-Headset Mutation Confirmation

A PC command returning exit code zero is not proof that a Quest reached the
requested state. Every host operation that can change headset state should use
an explicit receipt with this lifecycle:

```text
sent -> pending -> confirmed
                  \-> failed
                  \-> timed out (still reconcilable)
```

- **Sent** means the PC assigned an operation ID and issued the bounded command.
- **Pending** means the command was admitted, but authoritative device readback
  has not matched yet. A visible Meta permission prompt remains pending.
- **Confirmed** means a fresh, route-specific headset readback matches the
  desired effective state.
- **Failed** means the bounded operation failed and no matching state was
  established.
- **Timed out** means no match appeared within the operator window. Keep the
  receipt reconcilable because the wearer may answer a prompt later.

Keep the device identity, operation ID, command kind, desired state, observed
state, timestamps, and ordered transitions together. A desktop UI should show
the latest receipt and reconcile pending receipts whenever it refreshes the
corresponding headset status. Automation should receive the same receipt as
structured output rather than infer success from console text.

## Confirmation Sources

Use the narrowest independent source that can prove the effect:

| Mutation | Confirmation evidence |
| --- | --- |
| APK install | Package Manager completion plus a refreshed package/version inventory |
| File or structured data upload | Remote size or digest; for app-owned data, app schema validation and reload acknowledgement |
| App launch mode | App-owned selected target and guard state, plus foreground readback when foreground placement is the claim |
| Accessibility control | The enabled-service setting contains or omits only the intended service |
| Wi-Fi ADB request | Effective listener/status readback; prompt launch or request admission alone is pending |
| Wi-Fi ADB connection | The exact endpoint appears in the refreshed ADB device inventory |
| Keep awake | Effective power-policy fields such as `mStayOn` or Quest power-manager autosleep state |
| CPU/GPU override | Fresh `getprop` values match the requested levels, or are empty after restore |

Do not use a nearby signal as a substitute. In particular, a proximity state
of `CLOSE` can simply mean the headset is being worn; it does not prove that a
keep-awake override is active.

If a command throws after it may have partially changed state, retain a failed
or pending receipt and perform the same bounded readback before retrying. Never
silently resend a non-idempotent mutation merely because the first process
timed out.

## Typed On-Headset Operator Surface

When a normal Quest app needs a PC operator surface, prefer a fixed typed
contract over an arbitrary shell proxy:

- expose only enumerated commands and bounded values;
- protect the exported operator provider so ordinary third-party apps cannot
  call it (for an ADB-shell-only surface, a platform permission such as
  `android.permission.DUMP` is one useful gate on tested builds);
- give every request an ID and return a structured result plus current state;
- use a separately installed, same-signer helper only for the narrow secure
  settings that need one-time USB provisioning;
- preserve unrelated enabled Accessibility services when changing one service;
- never accept host-provided shell text, component names, or filesystem paths.

For a hotloaded app-owned JSON file, a provider can use bounded Base64 chunks
with ordered offsets, a total-size ceiling, SHA-256 verification, schema
validation, and atomic activation. This avoids granting a desktop tool broad
raw access to `/Android/data` and makes the final reload acknowledgement the
confirmation point.

## Quest-Specific Recovery Details

Wi-Fi ADB remains an explicit wearer-controlled feature. USB ADB can provision
the narrow helper once, while the headset app requests Meta's visible Wi-Fi ADB
permission. Re-request after boot is a preference to show that attended gate;
it is not proof that the listener is active. The PC should continue to report
pending until effective status changes, and should offer a separate disable
operation with readback.

When restoring Quest performance overrides through ADB, some builds reject an
empty value passed as a separate `setprop` argument. Send the fixed command as
one shell expression with a quoted empty value, then confirm both properties
are empty. For example:

```powershell
adb -s <serial> shell "setprop debug.oculus.cpuLevel ''"
adb -s <serial> shell "setprop debug.oculus.gpuLevel ''"
adb -s <serial> shell getprop debug.oculus.cpuLevel
adb -s <serial> shell getprop debug.oculus.gpuLevel
```

Treat these property names as build-specific and revalidate them after Horizon
OS updates.

## Acceptance Checklist

- Every state-changing desktop route emits `sent`, then `pending`.
- `confirmed` is impossible without a fresh matching device readback.
- A wearer prompt can remain pending and later reconcile to confirmed.
- A mismatch, timeout, or command error never produces false confirmation.
- Restore operations have their own receipts and confirm the original state.
- Tests cover both matching and mismatching readback, including one real Quest
  cycle for every authority class used by the product.
