# Quest Memory Profiling

Use this conditional playbook for a memory-growth or native-allocation question.
It does not add a prerequisite to ordinary builds, installs or feature work.
Use the selected provider and existing target authorization; profiling is an
instrumentation effect, distinct from read-only memory counters.

## Establish comparable observations

Bracket bounded samples with exact serial, boot identity, PID and process birth.
A PID change ends that series; do not stitch replacement actors into one slope.
Keep workload, APK, lifecycle, foreground state and sampling schedule comparable
for a baseline/candidate/baseline comparison. Record uptime and raw units rather
than treating host collection duration as the sample timestamp. Preserve full
stdout, native completion and denials through the existing
[artifact discipline](artifact-and-evidence-discipline.md).

Read Native Heap, Java Heap and Graphics separately. In `dumpsys meminfo -d`,
the detailed Native Heap PSS column is proportional resident accounting; Heap
Alloc reports allocator accounting. Retain the displayed summary headers and
Android version, but check the summary accounting implementation as well:
[AOSP Debug.MemoryInfo](https://android.googlesource.com/platform/frameworks/base/+/aml_uwb_330810010/core/java/android/os/Debug.java)
returns native Private Dirty for the Native Heap summary and combines Dalvik
Private Dirty with ART private memory for Java Heap. A summary displayed under
a PSS heading therefore need not equal the detailed Native Heap PSS. Use that
detailed PSS field for a native PSS slope; keep Heap Alloc and summary values
separate. These AOSP definitions do not identify an unverified Quest firmware
implementation. PSS apportions shared pages, RSS counts resident pages,
and USS concerns uniquely owned resident pages; Private Dirty alone is not USS.
Keep parser labels and table headings with values. A larger allocation counter,
resident footprint or graphics summary answers a different question.
See [Android meminfo definitions](https://developer.android.com/tools/dumpsys#meminfo).

If shell access to proc mappings is denied, preserve the denial. On a tested
debuggable Quest app, a target-scoped `run-as` read of full proc smaps succeeded
where a shell smaps_rollup read did not. This is an observed fallback, not a
portable permission guarantee: qualify the installed app/build and exact proc
route. A long sequential smaps read is not an instantaneous snapshot. Grouping
malloc-labelled mappings locates resident memory, not allocation ownership,
growth rate or a leak.

## Qualify collection before interpreting a heap profile

Use the device's advertised Perfetto data sources to discover heap-profiling
support. Permission denial while listing a heapprofd executable does not prove
that the service is unavailable or that the target is eligible. Actual attach
and stack-bearing records establish the tested route. Android user builds
require the applicable debuggable/profileable eligibility; see the
[official heap profiler](https://perfetto.dev/docs/data-sources/native-heap-profiler).

Choose configuration delivery supported by the device version. Perfetto
supports stdin delivery and, on applicable Android versions,
`/data/misc/perfetto-configs`; a readable host-pushed file in another directory
need not be readable by the tracing service. Preserve rejected delivery and
visibility attempts rather than weakening permissions. See
[Perfetto configuration](https://perfetto.dev/docs/concepts/config).

Retain trace/config hashes, exact target and bounded duration, terminal native
capture, actor brackets and capture health. Inspect trace stats for client
errors, shared-memory buffer overrun, disconnects and empty callstacks. An
overrun truncates the profile: retain it as partial evidence, never credit the
requested full window or treat absent later frees as retained ownership.
Changing sampling interval or shared-memory capacity creates a new collection;
keep the failed original immutable.

## Analyze churn and retention separately

Use an exact pinned official Trace Processor executable for host-only SQL when
UI or foreground access is unnecessary. Record its release/hash, SQL, raw output,
stderr and exit; retain stack ancestors, mapping build IDs and relative PCs.
Unsymbolized APK frames and opaque vendor symbols remain unresolved. See
[Trace Processor CLI](https://perfetto.dev/docs/reference/trace-processor-cli).

Allocation and free weights estimate sampled malloc activity. Report positive
allocation, frees and net separately for each dump and callsite. Inclusive
ancestor groups overlap and cannot be added. Pipeline-creation/driver ancestors
can establish compilation churn without identifying a retention bug.

A completed coarse profile can show heavy paired allocation/free and zero net
while an earlier unprofiled series grows. Zero sampled net does not exclude
small retained growth; late attach excludes preexisting allocations, and malloc
profiling does not attribute GPU or direct mmap memory. Sampling and unwind or
client-blocking overhead can alter the workload. Keep those costs and the
sampling interval (bytes) with the conclusion; do not infer a leak, its cause or a fix
from churn alone. Device/build-specific observations remain empirical evidence,
not Quest-wide guarantees.
