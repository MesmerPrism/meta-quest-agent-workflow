# Long-Running Watchdogs And Device-Side Helpers

Long Quest workflows can fail for reasons unrelated to the app under test:
display sleep, virtual proximity state changes, mount state changes, foreground
loss, headset prompts, or camera provider stalls. A watchdog can keep a lab run
stable, but it is a device-setting intervention and must be explicit.

## Default: Use The Existing QFM Supervisor

For an authorized request to keep a Quest awake, ignore wear/proximity drift,
or maintain a long lab run, use QFM's existing standalone
`helpers/quest-proximity-watchdog` before creating any custom helper or host
script. QFM owns its implementation, build, start/status/stop interface and
receipts. This playbook is the Meta Quest Workflow entrypoint.

For an installed MQW skill, read the optional local-only
`references/local-quest-awake-helper.json` first. Validate it using the procedure
below, then read `helpers/quest-proximity-watchdog/README.md` in that exact QFM
checkout. An explicitly selected QFM checkout is the alternative when no valid
locator exists. Bind the source commit, helper JAR SHA-256 and script version
before effects. Do not guess a machine path or use a historical worktree as
the canonical helper.

The reviewed source is publicly available at the immutable
[QFM helper revision](https://github.com/MesmerPrism/QuestIonAble-File-Manager/tree/2b27d8bc4de62228336e7a62df020ec00ab7f07c/helpers/quest-proximity-watchdog),
with its [dated live validation record](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/2b27d8bc4de62228336e7a62df020ec00ab7f07c/helpers/quest-proximity-watchdog/LIVE_VALIDATION.md).
[Draft PR 112](https://github.com/MesmerPrism/QuestIonAble-File-Manager/pull/112)
is open; merge to the intended
[main source location](https://github.com/MesmerPrism/QuestIonAble-File-Manager/tree/main/helpers/quest-proximity-watchdog)
is pending. Use the pinned revision or a separately qualified local source;
the main URL does not establish availability. If the helper is unavailable,
report that source-resolution gap; do not silently substitute a minimal watchdog.

QFM's ordinary `device keep-awake` operation is a one-shot policy command, not
a renewing supervisor. Fleet's managed awake-control contract applies only to
a selected managed operation; standalone local supervision does not require
Fleet enrollment, a managed snapshot or Fleet command authority.

Start with read-only status and current proximity/power readback. Do not push,
start, replace or renew a helper merely to observe it. Preserve a healthy
existing helper and any deliberate manual awake/proximity policy. Start or
replace only within the requested scope, using the owner's exact operation.

The source entrypoint is `helpers/quest-proximity-watchdog/tools/Invoke-Watchdog.ps1`
with `-Action start|status|stop`, selected `-Adb` and exact `-Serial`. Read the
owner README for build prerequisites and start confirmation. Both `status`
and `stop` require the retained local built JAR to verify the installed
content-addressed JAR before executing its read-only status entrypoint; do not
build or push a replacement merely to observe or stop an existing owner.
`stop` verifies the current boot/PID/birth/command-line/lock owner before
writing its fixed marker and waiting for process absence. It never builds,
pushes, starts another helper or restores policy. Host verification remains
separate from the linked live record: two Quest headsets each completed normal
policy restoration, default startup, two accelerated finite-hold renewals,
owned stop without restoration, and final default startup. Those checks did
not establish six-hour default renewal, eight-hour endurance, host-disconnect
survival, reboot persistence or app/media readiness.

A separate [11 November default-cadence follow-up](https://github.com/MesmerPrism/QuestIonAble-File-Manager/blob/0d6165ba4081939ff56e63340dd6720e96aa820e/helpers/quest-proximity-watchdog/LIVE_VALIDATION.md#default-cadence-follow-up--11-november-2026)
records four actual six-hour renewals per headset and more than 24 hours of
sampled operation by the same standard helpers, with zero recorded hold
failures. Incomplete status observations remain unknown. This is sampled
helper/hold evidence; continuous display readiness, protected-wearer readiness,
OpenXR, camera delivery and wearer comfort remain separate claims.

Current owner, artifact, process and effective state still require fresh readback.

## Validate The Optional Local Helper Locator

`references/local-quest-awake-helper.json` is installation data, outside the
canonical skill and public source. It records `repository_root`,
`source_repository`, full `source_commit`, Git `source_tree`,
`source_worktree_dirty`, `source_status_fingerprint`, the relative `helper_root`
and a `source_files` array of relative paths and SHA-256 values. It grants no
execution, target, build or device authority. The MQW playbook resolver and
managed-skill verifier do not validate this separate QFM locator.

Before reading its helper as the selected source:

1. Require the expected repository to be
   `https://github.com/MesmerPrism/QuestIonAble-File-Manager.git` (equivalent
   canonical Git transport spelling is acceptable). Check the live checkout's
   origin and `git rev-parse --show-toplevel`; the latter must be the recorded
   resolved root. Reject a reparse-point root or helper files and any path
   escaping that root.
2. Require live `git rev-parse HEAD` and `git rev-parse 'HEAD^{tree}'` to equal
   the recorded full commit and tree. Require
   `git status --porcelain --untracked-files=normal` to be empty and the
   recorded dirty flag to be false. Its sorted status text fingerprint must
   equal SHA-256 of the empty string. A changed, stale or dirty checkout is not
   the qualified helper source.
3. Require `helper_root` to be exactly `helpers/quest-proximity-watchdog` and
   the inventory to include its README, `tools/Invoke-Watchdog.ps1` wrapper
   and upstream notice. Each path must be a repository-relative file under
   that helper root with no traversal. Recompute every recorded SHA-256 and
   require an exact match before using its instructions or wrapper. Follow
   the helper's own source/build pins as well; this locator is not a JAR
   acceptance receipt.
4. If any check fails, report the mismatch and use the user's explicit source
   selection or a verified immutable published commit. Do not rewrite locator
   identity or accept floating `main` merely to silence a mismatch.

Generate or refresh this local file only after a coherent clean QFM commit
and a fresh source/hash check. Keep it out of public Git. The established
managed-skill updater preserves unknown local reference files and reports them
as unmanaged; preserve this intentional locator during maintenance. If a
reinstall omits it, regenerate it from a newly qualified explicit checkout
rather than copying stale metadata. See [local playbook resolution](local-playbook-resolution.md)
for the separate MQW source-provenance contract.

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

Do not assume an ADB-launched helper, keep-awake policy, or proximity hold
survives a headset reboot. After reboot, re-establish a required mutable layer
only when the operator's authorization still applies. Otherwise, perform
read-only readiness checks and report the missing guard. Confirm display,
foreground, OpenXR, tracking, and source readiness separately.

## Boot And Foreground-Service Limits

A boot receiver, foreground service, or wake lock proves only its own bounded
application lifecycle. It does not prove mounted-headset or proximity state,
foreground adoption, OpenXR readiness, tracking, or an advancing source.

Android restricts background foreground-service starts according to platform
version, target SDK, service type, and current while-in-use permissions. Some
service types also cannot be started from `BOOT_COMPLETED`. Treat an accepted
boot broadcast or service start as one evidence row, then read back every
required runtime layer. Do not work around a denied or inapplicable start by
silently changing app, device, or permission policy.

Primary Android references:

- [background foreground-service start restrictions](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)
- [foreground-service types](https://developer.android.com/develop/background-work/services/fgs/service-types)
- [background optimization and delayed boot delivery](https://developer.android.com/topic/performance/background-optimization)
- [awake API selection](https://developer.android.com/develop/background-work/background-tasks/awake)

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

## Proximity And Awake Supervisor Contract

The established default uses a finite eight-hour Meta virtual proximity hold,
proactively renewed every six hours, and five-second drift polling. Preserve
an explicitly requested cadence and end condition. `UntilStopped` means the
supervisor runs until stopped; each underlying hold remains finite. A Windows
loop that only sets stay-awake and wakes a sleeping display is incomplete.

The supervisor must track its own last successful hold and renewal deadline
with monotonic elapsed time. A `CLOSE` readback, another helper's hold, a failed
request or an unconfirmed command does not establish its owned coverage.
Renew before owned coverage expires even while the display is awake and the
virtual proximity value remains `CLOSE`. If owned coverage is absent or
uncertain, report that condition and follow the owner contract instead of
claiming a protected run. Its success timestamp records successful bounded
command dispatch, not an authenticated native remaining-time timer; require
current virtual proximity and power readback independently.

Keep these observations separate:

| Observation | What it establishes |
| --- | --- |
| Helper process and fresh heartbeat | The exact supervisor is running |
| Successful hold plus monotonic renewal deadline | This supervisor's finite hold coverage |
| Virtual proximity `CLOSE`, `OPEN` or `DISABLED` | The service's virtual state at that observation |
| Wakefulness and display state | Awake/display evidence at that observation |
| Physical SensorLock, lock screen or Guardian state | A separate wearer/platform readiness boundary |
| Target-owned OpenXR/camera/frame evidence | The selected app/source's actual readiness |

`DISABLED` is not proof that the physical proximity sensor is disabled, and a
virtual hold does not clear a physical SensorLock screen. Preserve the attended
reboot and wearer gates in [mutation confirmation](host-headset-mutation-confirmation.md)
and [signal patterns](quest-signal-patterns.md).

Use the owner's start/status/stop scripts rather than reconstructing its
broadcasts or shell launch. Bind exact serial/transport, boot ID, JAR digest,
main class and argv, PID and process birth identity. A PID alone, process name,
old status file or prior boot's receipt cannot authorize replacement or stop.
A boot or process-identity mismatch invalidates the old live-helper claim.

After start, require fresh helper status and effective virtual proximity and
power readback; a host exit code proves dispatch only. If the display drifts,
the helper may repair authorized stay-awake/wake policy. If virtual proximity
drifts, it may repair the authorized hold. Record successful actions, failures,
renewal counts and fresh readbacks independently. Do not spam mutations on
every poll, and do not count a failed command as successful coverage.

For an explicitly selected diagnostic/provider-gap fallback, representative
read-only observations are:

```powershell
adb -s <serial> shell dumpsys vrpowermanager
adb -s <serial> shell dumpsys power
```

The platform-specific proximity operation belongs in the maintained helper,
not a copied one-liner or a new project-local implementation.

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
script merely because the run changed that state. Restore only when the user
requests it, an explicitly temporary experiment requires it, or the actual
owner contract requires it for a stated reason. Retain the requested final
policy and report it. Stop only run-owned watchdogs whose requested lifetime
has ended; another operator may intentionally keep one running.

## Idempotence

A good watchdog is idempotent:

- It reads first.
- It repairs observed drift only when readback is not the desired state.
- It also renews before its own successful finite hold expires, even when
  readback remains desired; drift repair alone is insufficient.
- It records successful renewals separately from drift repairs and failures.
- It reports current state even when no repair was needed.
- It does not spam power/proximity commands on every poll.

This avoids redundant repairs while preserving proactive renewal. Another
helper's desired-state readback does not extend this helper's coverage. Prefer
a single healthy existing owner; do not start competing supervisors for the
same request.

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

- helper source commit, script version and exact JAR SHA-256;
- host provider, exact serial/transport and boot ID;
- PID, process birth identity, main class and argv;
- fresh status/heartbeat and whether process identity was verified;
- last successful hold, monotonic coverage/renewal deadline and renewal count;
- failed or uncertain requests, separately from successful coverage;
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
