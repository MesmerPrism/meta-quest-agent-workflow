# Meta Horizon MCP And hzdb

Meta Horizon Debug Bridge (`hzdb`) can be used as a CLI and as an MCP server.
Treat it as an optional Quest-specific provider beside ADB.

Some local notes or messages may shorten this to "hdb"; in this repository the
command name is written as `hzdb` unless a future Meta release documents a
different binary name.

## Read-Only Discovery

Check whether Node, npm/npx, and `hzdb` are available:

```powershell
node --version
npx --version
npx -y @meta-quest/hzdb --version
npx -y @meta-quest/hzdb --help
```

Then inspect the relevant command group:

```powershell
npx -y @meta-quest/hzdb device --help
npx -y @meta-quest/hzdb capture --help
npx -y @meta-quest/hzdb app --help
```

The exact subcommands can change. Prefer `--help` output from the installed
version over copied commands from old notes.

On the `hzdb` surface checked on 2026-06-14, `capture` documented only
`screenshot`; it did not expose a video recording command. Use
`quest-capture-stack-notes.md` before assuming the built-in Quest recorder is
ADB-controllable.

## MCP Server Shape

A typical MCP registration uses `npx`:

```json
{
  "servers": {
    "meta-horizon-mcp": {
      "command": "npx",
      "args": ["-y", "@meta-quest/hzdb", "mcp", "server"]
    }
  }
}
```

Choose one registration route per agent or IDE. Multiple MCP server entries
for the same device can make logs and captures harder to attribute.

## Provider Selection

Use `hzdb`/MCP when it gives a Quest-specific capability:

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

Some `hzdb` builds expose app or permission helpers. If available, prefer the
documented command from `hzdb app --help` and record the `hzdb` version.

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

`hzdb` can be used as a bounded proximity/stay-awake helper when the installed
version supports it. A public-safe example shape is:

```powershell
npx -y @meta-quest/hzdb device proximity --device <serial> --disable --duration-ms <ms>
```

Always verify this against `hzdb device proximity --help` on the machine that
will run it.

Do not leave a headset in altered proximity or stay-awake state by accident.
Record the requested duration, final power/proximity readback, and restore
instructions.
