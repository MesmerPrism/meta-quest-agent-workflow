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
  launch, capture, validation, cleanup, and evidence projection.
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

## Documentation Rules

- Use placeholders such as `<serial>`, `<package>`, `<activity>`, `<path-to.apk>`,
  and `<out-dir>`.
- Keep state-changing operations distinct from read-only inspection, and
  require effective headset readback before calling a dispatched mutation
  confirmed.
- Keep high-rate media out of generic JSON control/status channels.
- Treat Accessibility foreground monitoring as a privacy-minimized,
  user-enabled diagnostic capability, never HOME interception or kiosk policy.
- Prefer primary Android, OpenXR, and Meta sources for platform claims.
- Use `pwsh` for repository scripts; Windows PowerShell 5.1 is not the current
  workflow host.

## Validation

Before publishing documentation changes, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-public-safe.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-rusty-morphospace-routing.ps1
git diff --check
```
