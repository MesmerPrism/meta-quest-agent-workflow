# Maintainer contracts

Read the applicable rule when changing device procedure, provider contracts,
platform claims or evidence policy. This reference preserves detailed guidance
from the root entrypoint; it introduces no extra per-iteration checklist.

## Documentation Rules

- Use placeholders such as `<serial>`, `<package>`, `<activity>`, `<path-to.apk>`,
  and `<out-dir>`.
- On development devices, retain authorized device/app/runtime changes by
  default and report deltas. There is no assumed default setup. Read baselines
  only for identity, measurement, the requested action or correctness. Restore
  only on user request, for an explicitly temporary experiment, or for an actual
  owner requirement with a stated reason; mutation ownership alone is not a
  restoration requirement. Continue cleanup of run-owned live workers,
  recorders, ports, forwards, coordination resources and temporary artifacts.
- Keep state-changing operations distinct from read-only inspection, and
  require effective headset readback before calling a dispatched mutation
  confirmed.
- Treat an ADB `uid=2000(shell)` lease as transport, not proof that a saved-source
  Wi-Fi transition is supported. Verify reflective member names against the
  target framework before classifying a lookup failure as missing authority. In
  AOSP Android 14, `NETWORK_SELECTION_ENABLED` is the enabled-status field,
  `DISABLED_NONE` is the no-disable-reason field, and
  `NETWORK_SELECTION_ENABLE` is a diagnostic label rather than a field. Require
  target readback before claiming that a transition works.
- For APK-to-shell work, use
  `docs/apk-shell-capability-playbook.md`. Keep Windows administrator, Android
  shell, and Android root identities separate; diagnose attribution, transport,
  API authority, effect, and cleanup as distinct layers.
  For the tested offline-hotspot and BLE composition and pinned source map, use
  `docs/offline-hotspot-shell-ble-handoff.md`.
- Treat Quest reboot as an attended recovery boundary. ADB reconnect and
  Android boot completion prove transport/OS state only; require the physical
  power-button/wearer gate, cleared sensor-lock/Guardian state, valid advancing
  Shell vsync, and target-owned requested-rate OpenXR readiness before
  continued XR work.
- For boot Wireless Debugging and channel updates, use
  `docs/boot-wireless-adb-qualification.md`. Keep helper preference/request,
  actual TLS readiness, automatic recovery and XR readiness separate. Preserve
  measured firmware results separately from suspected causes and untested
  successors; use the linked owner examples without inventing helper authority.
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

