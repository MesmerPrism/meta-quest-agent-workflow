# Quest display capture and browser source entrypoints

This map covers headset-display capture to a host/browser. Camera2 and
Passthrough Camera streaming are separate application pipelines. Published
source, a successful encoder build, historical device evidence and current
runtime adoption establish different facts.

## Choose the source before the viewer

| Route | Producer | Host/browser role | Boundary |
| --- | --- | --- | --- |
| QMS scrcpy browser | Matching scrcpy server captures physical-display AVC | C# reader, loopback WebSocket, WebCodecs/canvas | Eye/crop controls change presentation, not native scene coverage. |
| Independent shell mirror | Version-bound shell display mirror to owned MediaCodec Surface | RMANVID1 to Hostess receiver or QMS bridge | Genuine Android shell privileges; often warped stereo display pixels. |
| App MediaProjection | Real Activity consent and projection foreground service to encoder Surface | Independent RMANVID1 receive/decode | Consent/session and Android version rules still apply. |
| Native coherent capture | Installed typed capture service to owned AVC encoder Surface | External helper stdout, Base64 decoding, RMANVID1 reader | Selected eye/framing before encoding; sole native capture ownership. |
| Meta/MQDH Cinematic | Opaque Meta producer/presentation | Hostess supervises the reviewed Windows casting process | No owned browser packet feed follows from a visible Cast window. |
| ADB still/file/stdout | PNG, finalized screenrecord MP4 or supported Annex-B H264 stdout | Byte-preserving output or host parser/decoder | Raw H264 alone is not a browser video URL; provider/version limits apply. |

See [capture taxonomy](capture-source-taxonomy.md) and
[capture stack notes](quest-capture-stack-notes.md) for screenshots, recorder,
MediaProjection and capture-policy details.

## Published code and setup

The immutable links identify reviewed source. They do not substitute for the
selected owner's current configuration or grant device-operation authority.

- [QMS browser guide](https://github.com/MesmerPrism/QuestMultiStream/blob/7d6c1f1a03de684e6a2b426071f4903a30220a43/docs/BROWSER_MONITOR.md):
  start at `src/QuestMultiStream.Browser/Program.cs`, `ScrcpyStartup.cs`,
  `ScrcpyVideoReader.cs`, `CaptureFanout.cs`, `BrowserConnection.cs` and
  `wwwroot/app.mjs`. The public scrcpy baseline is independently usable with
  its documented host/tool/device selection.
- [Independent Quest producer and build guide](https://github.com/MesmerPrism/rusty-quest/blob/031f7c360dad17aac1aac064d80fa0a8dcff2207/apps/display-stream-android/README.md):
  inspect `ShellDisplayMirrorMain`, `DisplayStreamService`, `H264SurfaceEncoder`,
  `Rmanvid1Writer` and per-attempt retirement; build with
  `tools/Build-DisplayStreamAndroid.ps1`.
- [Native Quest helper and build guide](https://github.com/MesmerPrism/rusty-quest/blob/031f7c360dad17aac1aac064d80fa0a8dcff2207/apps/native-browser-capture-android/README.md):
  inspect `NativeBrowserCapture`, `ShellApplicationContext`, `NativeVideoWire`
  and `VideoRequestOwner20`; build with `tools/Build-NativeBrowserCapture.py`.
- [Hostess display routes](https://github.com/MesmerPrism/rusty-hostess/blob/19ef8a2950afd5025b34f7135b1b00671af98ef1/docs/DISPLAY_STREAMS.md)
  and [owned child adapter](https://github.com/MesmerPrism/rusty-hostess/blob/19ef8a2950afd5025b34f7135b1b00671af98ef1/docs/OWNED_DISPLAY_ADAPTER.md):
  inspect `tools/hostessctl/display_stream.py`, `display_stream_qms.py`,
  `connectivity_media_receiver_rmanvid1.py` and `h264_preview.py`. The external
  QMS process entry is `tools/display_stream_qms.py`. These links are the
  published [PR #42](https://github.com/MesmerPrism/rusty-hostess/pull/42) candidate.
- [QMS native/owned integration](https://github.com/MesmerPrism/QuestMultiStream/blob/7d6c1f1a03de684e6a2b426071f4903a30220a43/docs/NATIVE_SQUARE_CAPTURE.md):
  inspect `NativeSquareCapture.cs`, `OwnedDisplayProducer.cs`,
  `AppCaptureAdmission.cs`, `CaptureOwnerService.cs`, `HubOwnerBridge.cs` and
  `wwwroot/capture-mode.mjs`.

The experimental owned/native QMS route requires an authenticated app-owner
bridge and durable capture-owner journal. That application owner is a separate
integration dependency; this source package is not a standalone public native
browser launcher. Do not invent credentials or replace its real admission with
a sample selection. The Quest native helper has its own documented CLI contract.

Quest and Hostess are AGPL; QMS is MIT. The independent browser adapter uses an
out-of-process protocol. Copying AGPL implementation into MIT source is a
separate licensing decision. No Meta APK, ELF, decompiled implementation or SDK
binary is supplied by these source packages.

## Wire, geometry and lifetime

[RMANVID1v1](https://github.com/MesmerPrism/rusty-quest/blob/031f7c360dad17aac1aac064d80fa0a8dcff2207/docs/DISPLAY_CAPTURE_WIRE.md)
uses the same 32-byte header and packet layout for the generic and native
producers. Generic emission clocks are populated; the native helper emits zero
for unavailable emission clocks. Neither those clocks nor codec PTS alone
measure end-to-end latency. Preserve codec configuration, keyframes, ordering
and bounded queues. The Windows native ADB-shell transport Base64-encodes stdout
to avoid observed LF-to-CRLF corruption; decode before packet parsing and keep
stderr separate.

Native capture uses a genuine shell Application/attribution and normally granted
capture permission with an installed typed interface. Match the documented
Driver source/version profile; no ordinary APK privilege entitlement or stable
cross-firmware API is implied. Native LEFT mono1280x1280 is produced before
encoding, unlike a browser crop of raw two-lens output. Historical BOTH output
and relative framing experiments do not establish calibrated absolute FOV or
official Cinematic equivalence.

Native Stop is global and asynchronous on the original service proxy. A session
label is telemetry, not a server ownership fence. Require sole native capture
ownership per selected headset. Retain uncertain originals and wait for owned
client retirement before replacement. Client EOF/reap does not certify a native
server Surface-release acknowledgment. Keep capture-source, application-media
and monitor-host Stop separate.

Viewer disconnect/reload is an observer event. It must not replace its producer
or another source. A mode change settles that target's original before starting
its replacement. The retained October 17 lineage demonstrated two native square
browser feeds, one target switching square/raw/square while the other advanced,
and normal Stop plus a fresh launch. Newly built publication artifacts do not
inherit those observations as current device or release qualification.

## Prompt for an implementation agent

Trace one selected route through the linked producer, encoder, wire reader,
host bridge and browser decoder before proposing another wrapper. Return exact
files, methods, commits and the minimal supported setup. Identify caller
identity/consent, geometry, private owner dependencies, Stop/next-Start behavior
and publication versus runtime evidence. Start read-only. For an authorized live
integration, prove advancing decoded/rendered frames, viewer reconnect, explicit
Stop and the next Start on one headset before adding a second. Follow the
[streaming evidence boundaries](quest-streaming-and-direct-link-gates.md).
