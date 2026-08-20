# Quest APK Build Lanes

Use this playbook to keep ordinary Quest APK iteration fast without weakening
candidate or publication evidence. It defines portable procedure only:

- the work environment owns project composition, feature locks, build-lane
  isolation, and workflow contracts;
- the app shell or Rusty Quest adapter owns the Android build implementation,
  package identity, signing, and APK inspection;
- this repository owns the reusable build/deploy/device sequence and evidence
  boundary.

A framework or historical application may supply useful measurements. It does
not become a current schema or authority.

## Choose One Lane Before Building

| Lane | Use it for | Source and cache policy | Required output |
| --- | --- | --- | --- |
| Warm iteration | An ordinary edit/build/test loop before a frozen candidate exists | Use the declared live source state and reuse stable, project- and lane-scoped intermediates. Do not clean or rematerialize on every edit. | An inspected thin development APK, exact artifact digest, focused-check result, build-phase receipt, and explicit limitations |
| Candidate or publication | Handoff, release, publication, or a reproducibility claim | Freeze an exact clean composition. Use a fresh candidate assembly boundary and the owner-selected non-daemon/no-configuration-cache profile. | A content-addressed inspected APK, full composition and feature lock, complete gates, signer/toolchain evidence, phase receipt, and retained run capsule |

The lane is independent of risk tier, validation tier, and device-operation
authorization. Moving to a stricter guard profile does not make an APK build
clean, and a warm build does not authorize installation.

Every device transaction still receives one exact retained APK and run capsule.
That invariant does not require compiler intermediates to be content-addressed
or the warm-iteration source checkout to be clean.

## Stable Intermediate Contract

Keep mutable intermediates under a deliberately short local root. Scope them by
project and build lane, and serialize writers to the same root. Separate at
least:

- Cargo Android targets from Cargo host targets;
- Gradle user home and build cache from the repository checkout;
- Android shell or wrapper intermediates from native products;
- final APK and evidence outputs from all reusable intermediates.

Do not key the whole mutable cache root by a full APK or source-composition
fingerprint. That produces a new cold build lane whenever any input changes.
Use stable lane identities plus explicit invalidation instead. Final APKs,
candidate outputs, manifests, and evidence remain immutable and content
addressed.

Generated wrapper manifests, lock files, resource inputs, and staged native
libraries must be written only when their bytes change. Do not delete their
parent tree as ordinary preflight. Tool and Rust target setup must be
idempotent: inspect first, install only a missing required component, and never
repeat an installer in the edit loop.

## Separate Invalidation Identities

The build owner should persist the effective inputs and digests for distinct
identities rather than one opaque fingerprint:

| Identity | Representative inputs | Invalidate |
| --- | --- | --- |
| Native | Rust dependency lock, target triple, ABI, compiler/linker flags, NDK, shaders or generated native sources | Native output and package assembly |
| Android shell | Gradle and Android plugin locks, Kotlin/Java sources, resources, manifest template, SDK/build-tools and Java identities | Shell compilation and package assembly |
| Package | App/package identity, activity, feature/payload manifest, native and shell output digests, signing policy | APK assembly, signing, and inspection |

Record the invalidated identity and reason. Unknown identity drift fails closed
or starts a fresh lane; it must not silently reuse a neighboring project's
cache. A signing or package-identity error should fail before expensive native
compilation.

## Warm Iteration Procedure

1. Declare the project, live source observation, feature selection, toolchain,
   package identity, signer policy, and stable lane root.
2. Run focused tests and the project's bounded iteration check.
3. Preflight the exact Java, SDK/build-tools, NDK, Rust target, signer, package,
   ABI, and path-length requirements before compilation.
4. Reuse the lane's Cargo, Gradle, shell, and product intermediates. Permit the
   Gradle daemon, configuration cache, and build cache only when the owner has
   validated them for this development profile.
5. Assemble the smallest APK that exercises the changed feature. Do not run a
   clean build, detached materialization, full repository aggregate, or device
   operation merely because one source file changed.
6. Inspect package/activity, SDK levels, signer and expected fingerprint,
   payload inventory, ZIP alignment, native ELF load alignment, and accidental
   private or debug payload leakage.
7. Retain an exact APK digest and a build-phase receipt. Install or launch only
   if the task actually requires device evidence.

A host-only build needs only its build-root coordination. Acquire the exact
headset resource immediately before install or launch, not while Rust or Gradle
is compiling.

## Candidate And Publication Procedure

1. Freeze the accepted multi-repository source composition, dependency and
   feature locks, package identity, runtime profile, toolchain, and signer.
2. Materialize or otherwise prove the clean input required by the project
   owner. Reject ambient feature variables and undeclared generated inputs.
3. Use the owner-defined Candidate profile. Prefer a fresh final assembly
   boundary, no Gradle daemon, and no configuration cache; record any retained
   compiler cache separately from the reproducibility claim.
4. Run the risk-selected complete gates once, assemble the candidate, perform
   full APK inspection, and preserve content-addressed outputs and evidence.
5. If device validation is required, pass that exact retained candidate into
   the default device loop. Never rebuild between inspection and installation.

Candidate evidence does not prove that an empty-cache rebuild is fast. Warm
evidence does not prove that a candidate is reproducible. Report them
separately.

## Timing Evidence

Record wall time for the whole build and owner-defined phases such as native
compile/link, wrapper preparation, Java/Kotlin/resources, dex, APK assembly,
native insertion, alignment, and signing. Also record:

- lane and cold/warm state;
- exact source and tool identities;
- which inputs changed;
- cache hit, miss, or invalidation outcome;
- task counts when the build tool provides them;
- whether install/device time is excluded.

Compare timings only when invocation, source, toolchain, mode, and environment
are equivalent. An immediate rerun is useful cache evidence but is not by
itself a feature-edit result. Treat a sub-minute result as an observation tied
to its receipt, never a portable SLA.

## Makepad-Derived Evidence Boundary

Makepad supplied two useful public patterns: isolate mobile Cargo targets from
desktop targets, and choose debug-versus-shipping native linkage deliberately.
The latter still requires shipping APK proof, including 16 KiB ELF load
alignment on applicable Android targets. The transferable rule is stable
lane-scoped intermediates plus explicit invalidation and inspection—not the
Makepad command surface, generated wrapper layout, or crate schema.

When importing another build system's optimization, reproduce comparable cold
and warm measurements, inspect the final APK, and implement the result in the
current Android build owner.
