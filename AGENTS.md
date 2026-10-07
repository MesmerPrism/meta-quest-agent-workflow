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

## Work from the applicable contract

Use [the playbook index](docs/playbook-index.md) to select the task's procedure.
For bounded documentation edits, read the relevant playbook and existing checks;
for device/provider policy changes, also read the affected section of
[Maintainer contracts](docs/maintainer-contracts.md). Do not load every playbook
for an unrelated edit. Keep long recipes in those focused owner documents.

Continue within existing user/session authorization. Ask only when material
intent is missing or an action expands scope; prior authorization remains valid.
Provider dispatch needs operation-specific effective readback before confirmation.
Preserve owner evidence byte-for-byte and keep validation, transport, app/runtime
acceptance and publication as separate claims.

- Prefer app-owned typed providers for supported operations; use raw ADB only
  for the documented bootstrap, provider-gap, diagnostic or recovery fallback.
  File Manager local and Fleet managed routes retain their separate contracts.
- Use explicit target identity and applicable machine-resource coordination.
  Read-only serial-scoped ADB does not require an ADB daemon lifecycle lease;
  disruptive daemon/transport work does. Live effects retain their actual gates.
- Treat Quest reboot as an attended recovery boundary. ADB/OS completion alone
  is insufficient: retain the physical power-button/wearer gate, cleared
  sensor-lock/Guardian, advancing Shell vsync and target-owned OpenXR readiness.
  Use [mutation confirmation](docs/host-headset-mutation-confirmation.md) and
  [signal patterns](docs/quest-signal-patterns.md) for the actual readback.
- Keep high-rate media out of generic control/status messages. Discovery remains
  descriptive and inert; platform adapters do not mint Manifold authority.
- Use primary Android/OpenXR/Meta sources for platform claims and `pwsh` for
  repository scripts. Windows PowerShell 5.1 is not the workflow host.
- Review affected instructions when routed guidance changes; edit only those
  decisions and keep focused links current. Managed skill changes still follow
  canonical source, provenance and resolver rules above.

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
