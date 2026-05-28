# Artifact And Evidence Discipline

Quest validation is only useful when the artifacts say exactly what was tested.

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
