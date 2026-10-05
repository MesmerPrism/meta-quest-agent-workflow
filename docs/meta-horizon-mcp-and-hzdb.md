# Meta Horizon MCP And Meta VR CLI

Meta VR CLI can be used as a CLI and as an MCP server. Treat it as an optional
Quest-specific provider beside ADB.

Older Meta Quest Developer Hub or editor-extension bundles may still expose the
same tool family as Horizon Debug Bridge (`hzdb`), and some local notes may
shorten that to "hdb". Use `metavr` for new manual setup examples; keep `hzdb`
as a compatibility name for installed bundles and historical traces.

## Meta XR Operator Is A Separate Surface

Meta XR Operator is not another name for Meta VR CLI. Meta documentation
reviewed on 2026-08-06 describes Operator as an experimental OpenXR API layer
distributed in the Meta XR Core SDK and as standalone prebuilt binaries. It
runs a local MCP server inside the target app process; the optional proxy or a
direct SSE client calls its built-in tools. The reviewed documentation did not
identify a separate supported C or JNI entrypoint for invoking those built-ins
without the MCP server.

On Quest, Meta's standalone instructions package the Operator `.so` and API-
layer manifest into the target APK. That is an app-integrated development
route, not system-wide access to arbitrary installed XR apps. Treat Operator
as optional experimental tooling and a black-box behavior reference, not as
production authority or proof that its proprietary native implementation is
available to a custom integration.

For an MCP-free design, implement the required bounded behavior in an app-
owned native bridge or custom OpenXR API layer and use the owning typed local
API, Binder, or authenticated localhost adapter. See
[OpenXR SDK, API Layer, And Tracking Boundary](openxr-tracking-boundary.md).

## Current Baseline

The [official generated CLI reference](https://github.com/meta-quest/agentic-tools/blob/main/docs/metavr-cli.md)
checked on 2026-10-05 names `metavr` and describes:

- manual CLI/MCP route: `npx -y metavr`;
- MCP server route: `npx -y metavr mcp server`;
- agentic skills through `meta-quest/agentic-tools`;
- MQDH/editor-extension routes that may bundle a specific build;
- one MCP registration route per agent or IDE.

Also check Meta release notes when debugging tool behavior. A stale MQDH or
editor bundle can lag behind the `npx` package and produce different device
discovery or command surfaces.

The current reference includes screenshot, performance/Perfetto,
documentation, app/file/device operations, UI/input, Store distribution,
Tapedeck, simulator and XR Operator proxy groups. These are advertised
capabilities, not a declaration that every group is enabled in this agent or
supported by the installed binary. UI/input tools do not authorize protected
approval automation. Store operations do not authorize publication. Generic
shell/ADB groups do not broaden an owning application's typed contract.

### Enabled MCP Metadata Versus CLI Help

Discover the actual enabled tool names first. Match Meta namespace names such
as `horizon`, `meta.*vr`, `hzdb`, `xr_operator` or `meta_mcp`; inspect the exact
matching tools' metadata and schemas. Avoid broad description searches that
mistake unrelated tools mentioning Quest or Meta for a configured provider.
Record names, input bounds, side effects and authentication requirements;
do not invoke device effects just to discover the interface.

No matching Meta MCP namespace was exposed in the initial reviewed agent
environment on 2026-10-05. A configured server name alone did not prove availability: its
configured bundled executable was missing. Existing cached CLI version/help
could still be inspected offline. Keep these states separate:

| Evidence | What it establishes |
| --- | --- |
| Enabled MCP tool metadata/schema | This agent can address those exact tool names; not device health or authorization |
| Server registration | A configured launch route; executable existence and successful startup remain separate |
| Installed CLI version and inert help | That executable's advertised command surface; not enabled MCP tools or device effects |
| Online generated docs or registry version | Upstream advertisement; not the installed version |

An isolated, non-device acquisition and help verification on 2026-10-05
checked npm `metavr@1.8.1`, which resolves to native `metavr 1.8.0.17.10`.
Package and executable versions need not match. The executable SHA-256 was
`f00ad6599714f7421616b3014b73fefcc8410e15e3a77605fce72bd576363d80`.
Two direct help runs and the isolated npm shim agreed on `122929` normalized
UTF-8 bytes, SHA-256
`518ac62ca865bee0f534f25d208ab98a47cd538d174426c3cc8168cbe1ee0dce`.
This inert check verifies advertised current help only. Subsequent separately
authorized stdio negotiation is recorded below; no device effects were tested.
The four closed diagnostic argument routes remained advertised, but the
[accepted evidence profiles](meta-vr-cli-evidence-profiles.md) still bind their
reviewed older provider and require deliberate revision before using another.

Use an already resolved executable for inert `--version`, `--help` and
`--markdown-help` checks. `npx -y metavr` may download or update software and is
not an offline discovery probe. Do not repair configuration, install tools,
start a server, alter credentials or update reviewed evidence pins merely
because discovery found a gap; perform those changes only when in scope.

## Installed Help Discovery

Resolve the already installed executable, then inspect inert host help:

```powershell
node --version
npx --version
& '<resolved-metavr-executable>' --version
& '<resolved-metavr-executable>' --help
```

Then inspect the relevant command group:

```powershell
& '<resolved-metavr-executable>' device --help
& '<resolved-metavr-executable>' capture --help
& '<resolved-metavr-executable>' app --help
```

The exact subcommands can change. Prefer `--help` output from the installed
version over copied commands from old notes.

If no executable is installed, the `npx -y metavr` routes above are optional
online acquisition/bootstrap operations, not substitutes for offline help.
Choose and record the intended package/version and executable identity before
using the acquired tool; a reviewed diagnostic profile retains its own pins.

### Negotiated MCP Discovery

A separately authorized stdio startup on 2026-10-05 negotiated protocol
`2024-11-05` with native `metavr 1.8.0.17.10`. `initialize` and `tools/list`
returned 38 complete tool schemas without pagination. No tool was called and
no device, forwarding or ADB daemon lifecycle operation was performed. This
proves that selected server startup and schema discovery worked; it does not
prove a headset effect, tool health or protected authority.

The returned schemas included these useful decision boundaries:

| Actual tool names | Advertised schema and execution boundary |
| --- | --- |
| `vr_docs_search`, `vr_docs_get_page`, `vr_api_search`, `vr_api_details`, `vr_api_stats`, `vr_assets_search` | Documentation/API/asset lookup; network results do not prove headset state |
| `metavr_cli_help`, `metavr_software_paths`, `metavr_auth_status` | Help, host paths and auth status; retain any paths/account facts privately |
| `device_logcat`, `device_screenshot` | Logcat has line/filter and `clear` fields; preserve the buffer. Screenshot has method/width/height; keep provider and dimensions explicit |
| `perf_trace_capture`, `perf_trace_capture_start`, `perf_trace_capture_stop`, `perf_session`, `perf_memory_snapshot` | Capture/session effects require duration, scope and terminal cleanup; `launch` can change app lifecycle |
| `perf_trace_analyze`, `perf_trace_compare`, `perf_trace_get_context`, `perf_trace_gpu_counters`, `perf_trace_hex_to_time`, `perf_trace_list`, `perf_trace_load`, `perf_trace_query_sql`, `perf_trace_thread_state` | Trace-analysis schemas; bind the intended artifact and do not infer device effects from analysis |
| `metavr_app`, `metavr_device`, `metavr_files`, `metavr_unity_setup`, `metavr_run`, `ui_actions`, `ui_dump`, `ui_exists`, `ui_select`, `ui_swipe`, `ui_tap`, `ui_type`, `ui_wait` | Broad host/device/action surfaces; select only the authorized operation. Generic `metavr_run` arguments are not an owner fallback contract; UI tools cannot approve protected prompts |

Annotations are hints, not effect proofs. For example, logcat advertises a
read-only hint while its `clear` argument can erase the buffer. Inspect the
selected arguments and current schema, and prefer the existing narrow owner
route. Do not turn this inventory into a generic autonomous dispatch registry.

An agent may still lack the new namespace until its client reloads the
configuration. Keep repaired registration, negotiated server metadata,
current chat tool inventory and executed effects as separate facts. A new
chat/client reload is not permission to exercise all discovered tools.

The subsequent authorized configuration repair selected the versioned native
executable from the verified official npm distribution. Startup through that
actual parsed registration again returned the 38 schemas. One read-only
`vr_docs_search` returned a successful response with three official developer
documentation URLs; its relevance did not establish Wireless Debugging policy.
No sign-in, device tool, forward or daemon lifecycle effect was exercised, and
the test server exited. This verifies the documentation lookup route alongside
startup/schema discovery, while device behavior remains unqualified.

After the user's client restart on 2026-10-05, the active chat exposed the
same 38 Meta MCP tools. Direct chat calls to `metavr_cli_help`,
`vr_docs_search` and `vr_docs_get_page` succeeded: search returned three
official documentation results and retrieval returned a complete 20,331-character
project-setup page from an exact search result path. This supersedes the
earlier current-chat namespace limitation and qualifies live help/documentation
access. These calls exercised no device tools or transport changes; device
provider health and physical effects remain separate qualifications.

Both the older CLI surface and the current official `capture` group checked
on 2026-10-05 expose only a still screenshot subcommand. A broad group headline
mentions screen recordings, but it is not an executable recording contract.
Verify actual subcommand help and schema rather than inferring video support.
CLI help is not physical validation of capture or cleanup. Use
`quest-capture-stack-notes.md` before assuming the built-in Quest recorder is
ADB-controllable.

## MCP Server Shape

A registration for the explicitly selected npm version can use `npx`:

```json
{
  "servers": {
    "meta-horizon-mcp": {
      "command": "npx",
      "args": ["-y", "metavr@1.8.1", "mcp", "server"]
    }
  }
}
```

Choose one registration route per agent or IDE. Multiple MCP server entries
for the same device can make logs and captures harder to attribute.
This sample is an optional configuration change and can acquire software;
it does not imply that a bundled `hzdb` launcher exists or has been repaired.
After an authorized configuration change, verify startup and actual exposed
tool names/schemas before claiming MCP availability. CLI help is available
offline as advertised syntax, not a negotiated MCP schema.

The tested repair ultimately used a resolved, versioned native executable
from the official distribution with arguments `mcp server --transport stdio
--no-telemetry --log-output none`. A shared npm-cache failure prevented the
first launcher attempt; it was reverted before selecting the native route.
Keep the exact executable/hash and preimage privately, preserve unrelated
configuration, and verify the parsed final record. Do not clear a shared npm
cache or invent adjacent runtime files to make a server start.

The current official reference advertises only `stdio` for its MCP server;
the older cached CLI advertised additional transports. Match the selected
binary's help rather than combining transports across versions. Similarly,
current `xroperator detect` and `call` commands are absent from the older
cached CLI. `detect` establishes an ADB forward and connects to the in-app
MCP server, so its name does not make it inert discovery. Keep forwarding,
app-session authority and cleanup within the selected operation's scope.

The reviewed upstream reference is
[commit-pinned here](https://github.com/meta-quest/agentic-tools/blob/3a8553d10a5a1bd1bf9beaaa950243fbbed3b9ea/docs/metavr-cli.md).

## Provider Selection

Use Meta VR CLI / MCP when it gives a Quest-specific capability:

```text
Quest docs/API search
Horizon OS behavior confirmation
device status
Quest screenshot provider
Perfetto capture helpers
proximity hold helpers
asset or package inspection
```

Use ADB when you need the platform baseline:

```text
install and launch
logcat
dumpsys
pm grant
appops
file push/pull
port forward
simple screencap
```

If both providers are used, record which one produced each artifact.

The cached CLI reviewed on 2026-10-05 advertised screenshot method `metacam`
by default; the accepted screenshot evidence profile explicitly selects
`screencap` and bounded dimensions. It advertised no dedicated `app` grant
command. Its `device wifi enable` performs host `tcpip` and auto-connect,
while disable disconnects and returns USB; this is host transport work, not
device-owned boot restoration. Keep those effects distinct from Kiosk's fixed
modern Wireless Debugging request and
[reboot qualification](boot-wireless-adb-qualification.md).

For preserved-buffer diagnostics, omit log-clearing options. A timed Perfetto
profile does not admit every `perf` command; current `perf capture --launch`
force-stops and launches the target and remains outside the closed profile.
`device`, `doctor` and XR liveness
status may probe or alter device/host resources; do not call them inert merely
because they appear under discovery or status labels. When only CLI help was
inspected, negotiated MCP schemas remain unverified; the later stdio
metadata-only qualification above establishes them separately.

## Permission Grants

Some Meta CLI builds expose app or permission helpers. If available, prefer
the documented command from `metavr app --help` or the installed bundle's
equivalent help output and record the CLI version.

ADB fallback:

```powershell
adb -s <serial> shell pm grant <package> android.permission.CAMERA
adb -s <serial> shell pm grant <package> horizonos.permission.HEADSET_CAMERA
adb -s <serial> shell pm grant <package> android.permission.POST_NOTIFICATIONS
adb -s <serial> shell appops set <package> PROJECT_MEDIA allow
adb -s <serial> shell appops get <package> PROJECT_MEDIA
```

Only grants declared by the manifest can succeed. Some Horizon OS permissions
also need manifest declarations or headset UI approval.

## Proximity Holds

Meta VR CLI / `hzdb` can be used as a bounded proximity/stay-awake helper when
the installed version supports it. A public-safe example shape is:

```powershell
npx -y metavr device proximity --device <serial> --disable --duration-ms <ms>
```

Always verify this against the selected CLI's `device proximity --help` on the
machine that will run it.

Do not leave a headset in altered proximity or stay-awake state by accident.
Record the requested duration, final power/proximity readback, and restore
instructions.
