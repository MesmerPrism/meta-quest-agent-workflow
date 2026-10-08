# Pinned Meta VR CLI Evidence Profiles

## Decision

Use the existing verified diagnostic adapter for execution and this additive
profile registry for provider identity, configuration hashes, bounded evidence,
normalized metrics, and cleanup receipts. Do not expose the broader Meta VR CLI
or MCP surface through an autonomous Quest loop.

The source registry is
[`recipes/meta-vr-cli-evidence-profiles.v1.json`](../recipes/meta-vr-cli-evidence-profiles.v1.json).
It overlays the executable recipe IDs from
[`recipes/verified-quest-diagnostics.v1.json`](../recipes/verified-quest-diagnostics.v1.json)
without changing that runner's authority.

## Verified Provider Pin

The following inert checks were performed without a headset on 2026-08-03:

| Field | Verified value |
| --- | --- |
| npm package | `metavr@1.3.2` |
| npm package version | `1.3.2` |
| CLI version | `metavr 1.3.2.2.2` |
| npm distribution integrity | `sha512-J3V0F+0e48Jd6Huxtcim6881Iw5kgLEBK+n4mamsG6LMBOE9ScEMomjHhKphtMkIsf6ViyI4PmrwtdG6SmZvFQ==` |
| npm distribution SHA-1 | `66a9ce615ad7388e28faf44f1b9a03f256f6191f` |
| normalized `--markdown-help` SHA-256 | `47b98fc99a544216975d7614b568ce41b5195b2a4c7d4a8f9a3ea6cac266e366` |
| normalized help size | `85230` UTF-8 bytes |

Normalization converts CRLF to LF, removes all terminal newlines, and appends
exactly one final LF. Two consecutive probes produced the same SHA-256. The
help surface confirmed `device health-check`, bounded `log`, `capture screenshot`, `perf
capture --mode vr --duration`, and `perf analyze-trace --focus frames`.

The profile-registry digest bound by synthetic and runtime receipts uses the
same text normalization. Git checkout line endings therefore cannot change the
registry identity or make an otherwise exact receipt platform-dependent.

The package integrity and help digest prove the selected distribution and
advertised interface. They do not prove a connected target, provider health,
Horizon OS compatibility, or any device-side effect.

An inert recheck on 2026-10-05 found cached package version `1.3.2` and
executable version `1.3.2.2.2`, but its normalized help was `86425` UTF-8 bytes
with SHA-256 `acd01fad7529b996e1a8e36bb6758c0439562fa89797df34dbdbfb3df2ded798`.
That does not match the reviewed pin above. Matching a version string alone
does not admit that executable to these profiles. Keep this mismatch as a
provider limitation; review a new profile deliberately rather than replacing
the accepted digest or claiming the old qualification still applies.

## Closed Profiles

| Profile | Existing provider recipe | Bound | Required evidence |
| --- | --- | --- | --- |
| `health` | `health` | 30-second deadline | provider JSON, exit status, health summary, no-mutation cleanup receipt |
| `logcat` | `logcat` | 1,000 lines and 60-second deadline; buffer preserved | bounded text, fatal/ANR/native-crash counts, provider exit receipt |
| `screenshot` | `screenshot` | 1024×1024 `screencap`, 60-second deadline | PNG hash/dimensions, provider JSON, black-frame limitation |
| `xr-frame-pacing` | `perfetto-vr` | 10-second default, 30-second maximum, 120-second process deadline | trace hash, frames-focused analysis summary, terminal capture cleanup |

Each profile contains the exact compact JSON used for its configuration hash.
An adapter must parse that string, compare it with the typed `config` object,
and verify its SHA-256 before constructing the already-reviewed provider
vector. A caller may narrow a duration or line limit within the declared bound;
it must emit the effective config and a new hash rather than pretending the
registry hash still applies.

Artifact paths are relative templates below
`artifacts/meta-tooling/<run-id>/`. Actual device identities, packages, logs,
screenshots, and traces remain private and outside the repository.

## Metric And Cleanup Receipts

Use
[`rusty.quest.workflow.meta_tooling_diagnostic_receipt.v1`](../schemas/rusty.quest.workflow.meta_tooling_diagnostic_receipt.v1.schema.json)
for the run summary. Preserve provider output and traces as separate artifacts;
the receipt binds their relative paths, hashes, sizes, normalized metrics, and
limitations.

Every declared metric is emitted as `reported`, `not-reported`, or `invalid`.
Do not manufacture a zero when Meta VR CLI or its Perfetto analysis lacks a
value. `xr-frame-pacing` requires a terminal cleanup receipt proving the
provider process exited and the run-owned trace capture is inactive. Health,
logcat, and screenshot still record their no-mutation or no-run-owned-resource
checks even when cleanup is not required.

These metrics are diagnostic evidence. They do not replace app-owned frame and
decode counters, current OpenXR session state, a wearer-visible oracle, or an
accepted Hostess/Kiosk/Manifold receipt.

## Conditional Exploration Of Newer CLI Capabilities

An isolated evaluation on 2026-10-08 inspected npm `metavr@1.8.1` and its
selected Windows native executable `metavr 1.8.0.17.10`. This is contextual
capability guidance, not adoption into the closed profiles above or a new
runtime, radio, controller, performance, or recenter qualification.

The evaluated executable was 61,544,696 bytes with SHA-256
`f00ad6599714f7421616b3014b73fefcc8410e15e3a77605fce72bd576363d80`.
Its normalized markdown help was 131,017 UTF-8 bytes with SHA-256
`f3c128d26c8e3fbe03fed39df0ff4828a05cdfdaeb12fbd1a436d74bba9bda4e`;
normalization also removed a leading BOM. An earlier observation of identical
executable bytes reported a different help digest. Bind the actual help/schema
and configuration context as well as the executable: version or binary hash
alone does not establish the effective interface. The cause of the difference
was not established. Preserve the accepted 1.3.2 pin and its later mismatch.

Local diagnostics worked with an isolated child configuration and no login,
`init`, global profile edit, skill installation, or MCP installation. Windows
configuration discovery also needed child-local `APPDATA` and `LOCALAPPDATA`,
not only `USERPROFILE`; retain the actual resolved configuration identity.
The inspected npm postinstall can append PowerShell profile/completion content,
so package acquisition is distinct from executing that installer.

The selected executable accepted `HZDB_ADB_PATH` pointing to an existing SDK
ADB and used its CLI backend. This avoided the automatic daemon-management
behavior encountered with the default backend in that evaluation. This is a
backend-specific observation, not a guarantee that future invocations cannot
start a missing server. Existing daemon identity and explicitly selected target
remain relevant operation evidence; backend selection grants no lifecycle
permission.

| Capability | Observed limit and conditional use |
| --- | --- |
| Local observation and documentation | Device info/battery, bounded logs, fixed read-only shell queries and official-doc search worked. `doctor --json` still emitted human text. Exit zero alone does not establish the requested output or effective target state. |
| Screenshot | Explicit `--method screencap` produced 3664×1920 PNGs despite requested 1024×1024 dimensions. It created a remote screenshot file, pulled through a host temporary file and saved the requested output. Preserve actual dimensions/artifacts and file cleanup scope; this does not conform to the old no-mutation 1024×1024 profile. Default MetaCam was not evaluated. A file-backed fallback remains an explicit capture source, not raw camera or pose evidence. |
| Input | Native `input key home --longpress` rejected the option before ADB. Android's built-in `input keyevent --longpress` uses its configured long-press timeout, not an arbitrary physical hold. The wearer reported recenter failure despite a UI reaction. A separately reviewed custom 2500ms experiment returned false on initial DOWN and never reached its hold. Neither result establishes physical Meta Touch system-button parity. |
| Performance | Help documents that `perf capture --launch` force-stops and launches the app. Omit that effect when observing a retained application state; trace capture/analysis still has its own artifact and terminal cleanup behavior. No live performance qualification was added. |
| MCP discovery | Inert discovery listed 38 tools; the broad `metavr_run` catchall exposed 154 command paths. This describes the advertised surface and does not admit generic autonomous shell, input, settings, package, transport, or lifecycle execution. |

Process-only telemetry suppression flags and MCP `--no-telemetry` did not
prevent essential consent lookup and event upload in the actual verbose logs.
Do not infer network silence or offline execution from those flags. No global
telemetry or account-consent setting was changed by the evaluation.

For the custom input failure, retained raw ADB stdout contained the worker's
terminal JSON even though the outer CLI omitted it on failure. There was one
DOWN attempt returning false, no repeat/UP attempt and no `SecurityException`.
AOSP distinguishes permission denial by exception from native injection
failure/timeout returning false. Its built-in initial event uses the same
virtual keyboard/source/unspecified-display construction; the built-in waits
for finish whereas the custom worker waited for result. That difference is not
an evidenced fix. Do not label the boolean false definitive missing permission
or silently retry with different sources, device IDs, displays, or settings.
Capture and wearer/app-owned pose evidence remain separate from dispatch.

Primary implementation references for those distinctions:

- [AOSP Android 14 InputShellCommand](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android14-release/services/core/java/com/android/server/input/InputShellCommand.java)
- [AOSP Android 14 InputManagerService](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android14-release/services/core/java/com/android/server/input/InputManagerService.java)
- [AOSP Android 14 InputDispatcher](https://android.googlesource.com/platform/frameworks/native/+/refs/heads/android14-release/services/inputflinger/dispatcher/InputDispatcher.cpp)
- [Official Meta VR CLI installation](https://developers.meta.com/vr/essentials/metavr-install/)
- [Scoped Meta VR CLI npm distribution](https://www.npmjs.com/package/@meta-quest/metavr)

## Meta XR Operator Boundary

Meta XR Operator is optional app-scoped instrumentation. It is an experimental
OpenXR API layer packaged into the target development app, runs an MCP server
inside that app, and requires an active focused XR session for live tools. On
Quest, full controller automation uses experimental-feature setup and image
capture requires MediaProjection consent.

Therefore Operator may provide app/session/tracking/frame observations and
test interaction for an opted-in build. It is not a generic device-readiness,
foreground, installation, performance, or visual oracle, and it is not a
production authority. Keep Operator evidence in a distinct app-diagnostic
claim class; never substitute it silently for one of the profiles above.

Primary references:

- [Meta Quest Agentic Tools](https://github.com/meta-quest/agentic-tools)
- [Generated Meta VR CLI reference](https://github.com/meta-quest/agentic-tools/blob/main/docs/metavr-cli.md)
- [Meta XR Operator overview](https://developers.meta.com/horizon/documentation/unity/meta-xr-operator/)
- [Using Meta XR Operator with Meta Quest](https://developers.meta.com/horizon/documentation/unity/meta-xr-operator/quest/)

## Validation

Run the offline contract and synthetic-receipt check:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\Test-MetaToolingEvidenceProfiles.ps1
```

Explicitly recheck the npm distribution, CLI version, and normalized help
surface without contacting a headset:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\Test-MetaToolingEvidenceProfiles.ps1 `
  -VerifyProvider
```

Neither form selects a device or runs a diagnostic recipe. `-VerifyProvider`
may populate the normal npm cache and requires access to the npm registry.
