# Notice

This repository packages public-safe Meta Quest workflow notes and scripts.

The repository's initial Quest, ADB, camera, capture, broker, and Meta VR CLI /
MCP / `hzdb` compatibility notes were adapted from public Rusty XR
documentation. Rusty XR is historical source provenance and a compatibility
reference, not the active routing model for current Rusty Morphospace work.

Historical source project:

- https://github.com/MesmerPrism/Rusty-XR

That historical source is MIT licensed. This repository remains MIT licensed.
Current public repo-family navigation lives in
`docs/rusty-morphospace-repo-routing.md`.

Sanitization changes:

- Local filesystem paths were removed.
- Private or machine-specific project names were removed.
- Device serials, package identities outside public examples, generated
  artifacts, screenshots, log dumps, and private run roots were removed.
- Agent coordination was rewritten as a generic local resource-locking pattern.
- Commands use placeholders such as `<serial>`, `<package>`, and `<activity>`.

Meta, Quest, Horizon OS, and related names are trademarks of their respective
owners. This repository is not an official Meta project.
