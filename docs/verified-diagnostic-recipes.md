# Verified diagnostic recipes

`recipes/verified-quest-diagnostics.v1.json` is the closed diagnostic catalogue
for unattended Quest iteration. Its adapter pins the npm package version,
verifies the observed CLI version before each invocation, validates the target
and optional package/tag inputs, and constructs the Meta VR CLI vector itself.
It also sets `ANDROID_SERIAL` to that validated serial for the provider process,
because compound routes such as Perfetto perform nested ADB probes that must
remain on the same headset when multiple devices are connected.

The catalogue intentionally exposes only health, foreground, bounded logcat,
one still screenshot, and bounded VR Perfetto capture. It has no general shell,
file mutation, app install, app launch, device-setting, or arbitrary Meta VR CLI
route. Health and foreground are transport observations. Logs, screenshots, and
traces are diagnostic evidence and never substitute for app-owned effective
state.

Use one new run-owned output directory per invocation. The adapter retains
stdout, any stderr, artifact hashes, the pinned provider identity, and the
authority class in `receipt.json`. Raw device identities and artifacts remain
private evidence.

The current `screenshot` recipe uses Android `screencap` for a deterministic,
bounded PNG. On an unworn headset, or for content rendered only through the XR
compositor, the provider can successfully return an all-black PNG. That proves
the capture route executed, not that immersive content was visually observed;
use app-owned readiness markers and attended casting or an in-headset check for
the visual oracle in that case.
