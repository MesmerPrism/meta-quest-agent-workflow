# Notice

This repository packages public-safe Meta Quest workflow notes and scripts.

Several sections are adapted from public Rusty XR documentation, especially
the Quest, ADB, camera, capture, broker, and Meta VR CLI / MCP / hzdb
compatibility workflow notes.

Upstream project:

- https://github.com/MesmerPrism/Rusty-XR

The Rusty XR source is MIT licensed. This repository keeps the same license.

Sanitization changes:

- Local filesystem paths were removed.
- Private or machine-specific project names were removed.
- Device serials, package identities outside public examples, generated
  artifacts, screenshots, log dumps, and private run roots were removed.
- Agent coordination was rewritten as a generic local resource-locking pattern.
- Commands use placeholders such as `<serial>`, `<package>`, and `<activity>`.

Meta, Quest, Horizon OS, and related names are trademarks of their respective
owners. This repository is not an official Meta project.
