# Quest shell capability investigation

Use this conditional playbook for an explicitly authorized development
investigation. The [APK-to-shell playbook](apk-shell-capability-playbook.md)
owns the existing companion/caller boundary. Shell-launched effects and
ordinary APK capabilities remain different distributions of authority.

## Identify the actual caller and implementation

Observed access used genuine Android shell UID 2000, its real Application,
context and attribution, with normal permission enforcement and SELinux still
enforcing. It was not root, Meta signing or an app borrowing another package's
identity. Standalone `app_process` can lack framework/JNI initialization an APK
normally receives; an unresolved native method or loader namespace failure is
not evidence that the target capability rejected a correctly initialized caller.
Reuse the selected owner bootstrap instead of inventing identity overrides.

Pin the exact target firmware, system APK/framework/library and actual API
shape for the proposed method. An implementation recovered from another
headset is a source lead until compared with current bytes. Keep these claims
separate:

1. Package/service/method is discoverable.
2. A requested permission is actually granted to this caller.
3. The call is admitted and returns a known result.
4. The requested operation has an observed effective result.

AppsFilter queryability edges establish visibility, not permission grants.
Source strings and a Binder descriptor do not establish command grammar,
registration, caller policy or effect. Recover the actual implementation before
proposing closed calls; do not guess transaction numbers, JSON commands or
property enables from names found in a binary.

## Useful investigated surfaces

| Surface | Reusable learning |
| --- | --- |
| Tracking/device diagnostics | Selected `dumpsys` routes produced useful state; this does not make arbitrary argument combinations or calibration writes read-only |
| Guardian Binder and Android service | An empty Binder dump and a useful running Android Service.dump were different routes; do not start/restart a service merely to collect an existing dump |
| Guardian automation receiver | Source registration and DUMP permission were recovered, while native command grammar/gating and effect/restore acknowledgement remained separate gaps |
| App functions | A source-backed recenter function succeeded through the actual AppFunctionManager callback and pose observation; an earlier broadcast did not establish the same effect |
| Own temporary files | Create/write/binary-read/delete in an owned shell namespace succeeded; this is not arbitrary app-private data access |
| App visibility signals | An ordinary APK-owned visibility subscription and broadcast route supported a Kiosk mode without requiring every close action to use a privileged shell path |

For an app function, inspect the current function identity and API, check whether
it is enabled, then correlate one original execution/callback with effective
state. A broadcast return code or a cancellation request is not proof of
execution, reversal or service termination. Reconcile a pending original call
before another mutation.

## Physical and lifecycle tests

Confirm which device the wearer is actually using. Earlier physical negatives
in one investigation were invalidated by a wearer/device mismatch. A valid
transport, process or screenshot does not bind a person's observation to that
headset. Keep the selected device/caller/service lifetime with each result.

For boundary/visibility experiments, record the original state and the
operation-specific effective signal, then test the intended physical action.
An observer callback, head-locked panel, boundary appearance and effective
kiosk foreground behavior are separate signals. Keep a deliberate escape
and inspect resume/reboot behavior if claiming persistence. Provider death
may quarantine stale active state without proving graceful prior withdrawal.

Prefer a supported ordinary APK mechanism when it meets the goal, and preserve
the shell variant as an explicit development capability. Neither route is
automatically store-approved. Preserve the original configuration and known
restoration path for temporary writes. Global Guardian restart, boundary
deletion/recalibration or a guessed native command is not a diagnostic query.
An unknown or missing restore result remains unresolved rather than being
cleared by broad process killing.

Keep raw tracking/room/boundary data and physical device identifiers private.
Promote reusable closed operations and sanitized fixtures to their owners;
see [module integration](quest-learning-integration.md).
