# Artifact And Evidence Discipline

Quest validation is only useful when the artifacts say exactly what was tested.

## Build Evidence Boundary

Keep reusable Cargo, Gradle, Android-shell, and product intermediates outside
the run evidence directory. Their cache hits can explain performance but are
not accepted artifacts. The build receipt should name the selected lane,
cold/warm state, exact APK digest, source and tool identities, invalidation
reasons, and phase timings. See
[Quest APK Build Lanes](quest-apk-build-lanes.md).

A content-addressed final APK does not require a content-addressed compiler
cache. Preserve the final APK, manifest, inspection report, and candidate
evidence immutably; describe mutable-cache use separately.

## Run Directory

Use a short directory outside source control:

```powershell
$runId = "quest-run-" + (Get-Date -Format "yyyyMMdd-HHmmss")
$out = Join-Path ".\artifacts" $runId
New-Item -ItemType Directory -Force $out | Out-Null
```

Do not commit:

- APKs
- screenshots
- logcat dumps
- captures
- camera frame payloads
- Perfetto traces
- generated diagnostic JSON from a private device
- zip bundles

## Mutable App State

For [pre-reset archives](adb-basics.md#retain-mutable-state-before-reset), bind the
exact package/user and installed artifact, observation interval, selected paths,
missing/inaccessible paths, archive byte count/digest and verified entry inventory.
Label a live copy as non-atomic unless an owner consistency receipt proves more.
Keep identity, enrollment, replay data and private paths out of public summaries.
Record excluded immutable content by its retained digest/reference. An archive
is evidence retention; restoration and terminal cleanup remain owner claims.

## PowerShell Runner Safety

PowerShell parameter and variable names are case-insensitive. Do not create a
local that differs from a parameter only by case, such as `$runtimeProfile`
beside `$RuntimeProfile`; use a role-specific name such as
`$runtimeProfileEntry` for parsed data.

Invoke programs explicitly and pass arguments as an array or separate
PowerShell arguments. Do not render a command string and then reparse or
evaluate it. Keep long human-readable labels in the run manifest rather than
embedding them in fragile command lines or deep artifact paths.

When a native command can emit useful failure evidence, preserve its real
stdout, stderr, and exit code through the repository-owned runner or an
equivalent bounded capture helper. Do not let PowerShell's
`NativeCommandError` wrapper replace the command's own report.

## Adapting A Helper For The Next Caller

For a changed launcher, collector or archive helper, bind its inputs and output
claims to the exact current invocation or installed-owner receipt. Derive
create-new logs, probes and receipts from that identity instead of replacing
ordinal names in copied scripts. Archive current installed state; a future APK
is not an archive prerequisite. Preserve the prior run and its unresolved state.

Exercise the actual next caller shape in a small focused case before selecting
the changed helper: include its real argument form, inherited environment and
resource boundary, producer stdout/stderr, consumer parsing and output claims.
A quoted absolute `-File` fixture alone misses an unquoted relative caller.
Native or `Console.Error` output can bypass in-process PowerShell redirection;
verify the owning runner's actual host-stream capture, not a matching log label.
Use the existing owner runner and resource contract; this pattern creates no
new executor, universal suite or APK gate.

Report prepared inputs, focused fixture proof, actual invocation, installed
source and device result separately. A helper labelled ready is not qualification.
Reuse unchanged hash-bound evidence; repeat only the affected caller case when
its arguments, environment, source or output contract changes. Record missed
process phases honestly; neither a later receipt nor a synthetic process fixture
fills a missing live observation or proves exhaustive capture.

## Minimum Run Manifest

Record at least:

```json
{
  "goal": "launch smoke test",
  "provider": "adb",
  "serial": "<serial>",
  "model": "<model>",
  "package": "<package>",
  "activity": "<activity>",
  "apk": "<apk-name-or-hash>",
  "started_at": "<iso8601>",
  "foreground_before": "<summary>",
  "foreground_after": "<summary>",
  "permissions_granted": [],
  "artifacts": {
    "logcat": "logcat.txt",
    "screenshot": "screenshot.png"
  },
  "result": "unknown"
}
```

If using a broker-style endpoint, include status and clock snapshots. If using
MCP or `hzdb`, include provider version and MCP server route.

For multi-stage watchdog or lifecycle tests, preserve a log snapshot at each
accepted gate or own a streaming logcat window. Small device buffers can drop
early connect/arm markers before final activity and panel logs arrive.

## Evidence Is Route-Specific

Label artifacts by owner:

- `adb_screencap`
- `hzdb_screenshot`
- `mediaprojection_display_composite`
- `app_private_camera_frame`
- `broker_status`
- `logcat_window`
- `perfetto_trace`

Two images can look similar but prove different things. A screenshot can show
what the headset mirror saw; it does not prove raw camera metadata, decode path,
or OpenXR layer ownership.

For a multi-hop stream, bind evidence to the layer that produced it. Receiver
bytes do not prove decode, decoded frames do not prove final render adoption,
and changing pixels do not prove cleanup or fatal-free lifecycle. Use
`quest-streaming-and-direct-link-gates.md` for the complete promotion ladder.

Preserve an application or Fleet owner receipt byte-for-byte. When a portable
summary is needed, use `rusty.quest.workflow.evidence_wrapper.v1` to bind the
owner schema and SHA-256 plus a sanitized claim, result, cleanup state,
artifact types, and limitations. The wrapper is not the owner receipt and
creates no authority. A `raw-adb-fallback` wrapper may claim only
`transport-observed` or `diagnostic-only`.

## Re-run After Code Changes

A device pass belongs to the exact app, manifest, scripts, properties, and
provider sequence that produced it. If any of those change, mark the previous
pass as historical and rerun the relevant check.

## Public Sharing

Before sharing artifacts publicly:

- remove serials and local usernames when possible;
- avoid screenshots that reveal private rooms, faces, notifications, or files;
- avoid full logs unless scrubbed;
- include package names only when they belong to a public example or the owner
  agrees;
- include exact commands and whether headset prompts were handled manually.
