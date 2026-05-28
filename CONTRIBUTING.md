# Contributing

Keep this repository portable and public-safe.

## Public-Safety Rules

- Use placeholders for device ids, local paths, package names, and activities
  unless the value belongs to a public example.
- Do not commit screenshots, log bundles, APKs, traces, captures, signing
  material, generated metadata dumps, or private run manifests.
- Do not document private app behavior as a general Quest capability.
- Do not claim that ADB, MCP, `hzdb`, shell helpers, or browser downloads can
  bypass Developer Mode, ADB authorization, runtime permissions, headset
  prompts, Store policy, or OpenXR focus/session ownership.
- Keep read-only, bounded capture, app lifecycle, file mutation, device setting,
  shell command, network forward, and destructive operations visibly separate.

Run the public-safety scan before publishing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-public-safe.ps1
```

## Documentation Style

- Prefer short command blocks with placeholders.
- Record what each command proves and what it does not prove.
- Use artifact directories outside git.
- Link to primary Android, OpenXR, and Meta documentation when asserting
  platform behavior.
