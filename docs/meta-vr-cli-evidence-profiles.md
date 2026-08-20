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
- [Generated Meta VR CLI reference](https://github.com/meta-quest/agentic-tools/blob/main/docs/hzdb.md)
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
