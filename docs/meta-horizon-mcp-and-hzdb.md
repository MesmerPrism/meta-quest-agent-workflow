# Meta Horizon MCP And Meta VR CLI

Meta VR CLI can be used as a CLI and as an MCP server. Treat it as an optional
Quest-specific provider beside ADB.

Older Meta Quest Developer Hub or editor-extension bundles may still expose the
same tool family as Horizon Debug Bridge (`hzdb`), and some local notes may
shorten that to "hdb". Use `metavr` for new manual setup examples; keep `hzdb`
as a compatibility name for installed bundles and historical traces.

## Current Baseline

Public Meta docs checked on 2026-06-16 describe:

- manual CLI/MCP route: `npx -y metavr`;
- MCP server route: `npx -y metavr mcp server`;
- agentic skills through `meta-quest/agentic-tools`;
- MQDH/editor-extension routes that may bundle a specific build;
- one MCP registration route per agent or IDE.

Also check Meta release notes when debugging tool behavior. A stale MQDH or
editor bundle can lag behind the `npx` package and produce different device
discovery or command surfaces.

## Read-Only Discovery

Check whether Node, npm/npx, and Meta VR CLI are available:

```powershell
node --version
npx --version
npx -y metavr --version
npx -y metavr --help
```

Then inspect the relevant command group:

```powershell
npx -y metavr device --help
npx -y metavr capture --help
npx -y metavr app --help
```

The exact subcommands can change. Prefer `--help` output from the installed
version over copied commands from old notes.

On the Meta CLI surface checked in June 2026, `capture` documented only a
still screenshot route in the tested bundle; it did not expose a generic video
recording command. Use
`quest-capture-stack-notes.md` before assuming the built-in Quest recorder is
ADB-controllable.

## MCP Server Shape

A typical MCP registration uses `npx`:

```json
{
  "servers": {
    "meta-horizon-mcp": {
      "command": "npx",
      "args": ["-y", "metavr", "mcp", "server"]
    }
  }
}
```

Choose one registration route per agent or IDE. Multiple MCP server entries
for the same device can make logs and captures harder to attribute.

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
