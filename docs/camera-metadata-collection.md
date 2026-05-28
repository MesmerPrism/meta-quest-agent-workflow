# Camera Metadata Collection

Camera metadata must be collected from the device and app context that will use
it. Do not assume that two headset models, OS releases, or camera IDs share the
same intrinsics, stream sizes, or projection relationship.

## Minimal ADB Collection

Start with read-only ADB probes:

```powershell
adb -s <serial> shell getprop ro.product.model
adb -s <serial> shell getprop ro.product.device
adb -s <serial> shell getprop ro.hardware
adb -s <serial> shell getprop ro.build.version.sdk
adb -s <serial> shell wm size
adb -s <serial> shell wm density
adb -s <serial> shell dumpsys display
adb -s <serial> shell dumpsys media.camera
adb -s <serial> shell cmd media.camera dump
```

Some builds expose more through `cmd media.camera dump`, others expose more
through `dumpsys media.camera`. Keep both outputs.

## App-Context Probe

If a foreground app or broker has permission to open Camera2, use an
app-context probe as well. System dumps can list capabilities, but app access
can still be affected by runtime permissions, Horizon OS policy, foreground
state, and stream configuration.

Collect:

```text
camera id list
logical/physical camera relationship
lens facing
available output sizes and formats
FPS ranges
active array and pixel array
sensor orientation
intrinsic calibration if exposed
distortion coefficients if exposed
lens pose translation/rotation/reference if exposed
stream open/capture success
first frame timestamp and size
```

For headset camera work, record both ordinary Android camera permission and the
headset-camera permission state.

## Target-Local Raster Versus Homography

A camera stream can be interpreted in at least two useful ways:

```text
target-local raster
  The metadata says where a rectangular source should land in the app's target
  coordinate system. Source UV is local to that target. This is explicit and
  easy to debug.

screen-to-camera homography
  The metadata says how display/screen coordinates map into camera/source UV.
  This is useful when the stream is intended to align with the headset's camera
  view or a measured projection relationship.
```

Name the mode in metadata. Do not infer it from whether the source is synthetic
or real camera. Synthetic test streams should carry the same kind of placement
metadata as camera streams when they are testing the same path.

## Invalid Source UV

"Invalid source UV" means the selected mapping asked for a source coordinate
outside the declared valid source rectangle. It is not the same thing as
"outside the desired on-screen target."

For target-local raster:

```text
outside target footprint -> border/effect region
inside target footprint -> source UV should usually be valid
```

For a homography:

```text
inside or outside a target footprint can still map outside the camera image,
because the mapping is screen-to-camera rather than target-local.
```

This distinction matters for debug colors. Use distinct colors for:

```text
target content
intended border/effect region
invalid source UV fallback
```

## Artifact Bundle

Store metadata in a timestamped artifact directory:

```text
device-properties.txt
display.txt
dumpsys-media-camera.txt
cmd-media-camera-dump.txt
app-camera-probe.json
broker-status.json
command-manifest.json
```

Do not commit generated bundles unless they are sanitized fixtures.

