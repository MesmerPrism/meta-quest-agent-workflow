# Agent Notes

This repository is public and portable. Keep committed content free of local
machine paths, private repository names, device serials, package identities,
generated APKs, screenshots, logs, pairing material, signing keys, and private
application behavior.

## Rusty Morphospace Routing

- This repository owns reusable Meta Quest device-operation procedure: ADB,
  install/launch, capture, logcat, Perfetto, Meta VR CLI, and evidence hygiene.
- `rusty-morphospace-work-environment` owns portable project composition,
  feature locks, workspace isolation, and workflow contracts.
- `rusty-quest` owns Quest/Android/OpenXR/Spatial SDK platform adapters,
  packaging, permissions, lifecycle, and effective-runtime receipts.
- `rusty-hostess` owns Windows CLI/API and WPF operator workflows for install,
  launch, capture, validation, cleanup, and evidence projection, including the
  opaque Meta/MQDH Cinematic presentation adapter. That adapter does not become
  a generic Quest or Manifold media source.
- `rusty-fleet` owns multi-headset Hub, Console, `fleetctl`, operator policy,
  enrollment/status projections, and no-ADB fleet monitoring. Its Quest Fleet
  Agent producer remains in the Rusty Quest platform lane.
- `rusty-manifold` owns command, session, stream, and control-transport
  authority. A local HTTP or WebSocket endpoint is an adapter into that owner,
  not a parallel broker authority.
- `rusty-lattice` owns tracked-space relations and poses; Matter and Optics own
  computational and renderer-neutral visual contracts.
- Public Rusty XR is historical/compatibility provenance only. Do not add new
  `rusty.xr.*`, `/rustyxr/...`, `RustyXr.*`, or Makepad-specific authority to
  current guidance.

Use [Rusty Morphospace Repo Routing](docs/rusty-morphospace-repo-routing.md) as
the public repo-family map. Keep historical attribution in `NOTICE.md`.

This repository is the canonical tracked owner for
`skills/meta-quest-workflow/SKILL.md` and its `agents/openai.yaml`. A downstream
installer may copy those exact bytes, record this repository and commit as
skill-source provenance, and generate separate local locator metadata. It must
remove rather than maintain a competing tracked skill entrypoint.

The local playbook locator must bind this repository's exact root, commit, Git
tree, clean status fingerprint, and docs paths. The installed resolver may use
that checkout only after live validation; otherwise it must use public files
pinned to the installed provenance commit, never floating `main`. Generated
locator files remain untracked local metadata and grant no execution authority.

## Documentation Rules

- Use placeholders such as `<serial>`, `<package>`, `<activity>`, `<path-to.apk>`,
  and `<out-dir>`.
- Keep state-changing operations distinct from read-only inspection, and
  require effective headset readback before calling a dispatched mutation
  confirmed.
- Treat Quest reboot as an attended recovery boundary. ADB reconnect and
  Android boot completion prove transport/OS state only; require the physical
  power-button/wearer gate, cleared sensor-lock/Guardian state, valid advancing
  Shell vsync, and target-owned requested-rate OpenXR readiness before
  continued XR work.
- Keep high-rate media out of generic JSON control/status channels.
- Treat Accessibility foreground monitoring as a privacy-minimized,
  user-enabled diagnostic capability, never HOME interception or kiosk policy.
- Prefer owning-application typed commands for repeatable operations they fully
  support. Default routine local work to File Manager inspected deployment,
  Kiosk launch/foreground control when applicable, and app-owned runtime
  evidence. Default managed target-set work to Fleet with current authority
  and effect-owner receipts. Keep local File Manager and managed Fleet
  execution on disjoint contracts, and gate raw ADB as bootstrap,
  provider-gap, diagnostic, or recovery fallback.
- Keep provider capability discovery descriptive and inert. It may identify
  typed actions, contract versions, effect owners, receipt schemas, placement,
  short-lived descriptor availability, authentication requirements, and
  exclusions, but must not contain invocations, paths, targets, endpoints,
  credentials, coordination records, raw arguments, shell access, MCP
  execution, or an execution grant.
- Keep reviewed Meta tooling profiles closed and hash-bound. Pin the npm
  package/version and distribution integrity, bind a normalized help-surface
  digest plus exact config digest, enforce bounded duration/output paths, and
  require metric and cleanup receipts without exposing raw CLI/MCP arguments.
- Treat JSON Schema validation as structural. Descriptor consumers must also
  enforce unique capability/action IDs, exact `TimeSpan`-tick timestamp/max-age
  correspondence, a 600-second maximum, zero future-observation skew, current
  freshness, and executable-vocabulary rejection across provider, capability,
  contract, effect-owner, receipt, and action identifiers. Reject `command` as
  an identifier token and reject generic ADB forms while preserving the
  explicit bounded `wifi-adb` and `wireless-adb` contexts. Timestamp strings
  must use RFC3339 date-time syntax before their semantic interval is checked.
  Normalize numeric offsets through `+23:59` and `-23:59`; do not impose
  .NET's narrower 14-hour `DateTimeOffset` constructor limit. Normalize an
  RFC3339 leap second (`:60`) to the following second before offset handling.
- Preserve owner-issued evidence byte-for-byte. A workflow wrapper may bind its
  schema and SHA-256 with a sanitized outcome, but must not add fields under the
  owner's schema or create an authority claim.
- Keep ordinary APK iteration and Candidate/publication assembly as explicit
  lanes. Mutable Cargo/Gradle/build intermediates may be stable, short, and
  project/lane scoped; final APKs and evidence remain content addressed. Require
  explicit invalidation plus comparable cold/warm phase receipts before making
  performance claims.
- Keep opaque operator-presentation evidence separate from owned media-plane
  evidence. A successful Hostess/MQDH Cinematic window may prove supervised
  presentation only; it does not prove recording, input forwarding, arbitrary
  2D-panel control, Meta device-session cleanup, or FOV restoration.
- Add MCP only after an owning application's typed CLI/local API registry is
  stable. Never expose raw shell, generic ADB arguments, arbitrary Android
  components/intents/paths/properties/processes, or caller-supplied authority.
- Distinguish app-owned OpenXR, co-resident native bridges over engine-owned
  handles, and loader API layers. API layers belong to the Quest adapter and
  target package; they do not expose engine semantics or authorize commands.
- Treat ordinary Android API layers as target-APK composition. Do not describe
  Termux or an unprivileged app as able to attach a layer to an existing
  session or inject one into arbitrary installed XR apps.
- Prefer primary Android, OpenXR, and Meta sources for platform claims.
- Use `pwsh` for repository scripts; Windows PowerShell 5.1 is not the current
  workflow host.

## Validation

Before publishing documentation changes, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-public-safe.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-rusty-morphospace-routing.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-AgentExecutionContracts.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-MetaToolingEvidenceProfiles.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-PlaybookSourceResolver.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-MetaQuestWorkflowSkill.ps1
git diff --check
```
