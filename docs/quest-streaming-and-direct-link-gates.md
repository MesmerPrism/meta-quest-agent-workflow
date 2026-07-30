# Quest Streaming And Direct-Link Gates

Use this guide for Quest/Quest or Quest/PC streaming, direct-link experiments,
and promotion decisions. It defines provider-neutral evidence gates; it does
not select a topology, authorize a device mutation, or make historical lab
verdicts current.

## Keep The Layers Separate

Treat these as distinct owners and evidence rows:

| Layer | Required evidence |
| --- | --- |
| Topology formation | The selected peer or host relationship exists for the current run. |
| Platform network observation | The participating app observes the intended current Android network. |
| Socket ownership | The owning process binds and uses the intended route; shell or sidecar reachability is not a substitute. |
| Control and session state | Current app-local or selected authority state for roles, peers, tracks, streams, revision, epoch, and lifecycle. |
| Media transfer | Receiver-observed bytes, packets, headers, codec configuration, and close reason. |
| Decode and import | Advancing decoded/imported frames plus drops, rejects, and failures. |
| Render adoption | Final-window or app-owned evidence that advancing remote frames reached the intended render path. |
| Cleanup | Routes, sockets, ports, sessions, processes, and run-owned state are closed or explicitly handed off. |
| Fatal boundary | The bounded acceptance window contains no relevant app, native, system-server, network, or platform fatal. |

One successful layer cannot promote another. A connected route does not prove
media transfer. Received bytes do not prove decode. Decoded frames or changing
pixels do not prove final render adoption. A successful frame does not prove
terminal cleanup.

When selected by the route, Manifold owns accepted command, session, stream,
peer, revision, replay, and revocation state. Keep every declared effect with
its explicit owner: Rusty Quest may own platform adapters and lifecycle; the
participating application owns its effective runtime; and the selected source,
processor, route/socket provider, codec, sink, display-adoption owner, and
cleanup owner may be distinct. Each owner proves only the effect declared by
its contract. When selected, Rusty Hostess owns Windows operator orchestration,
receiver, presentation, evidence, and cleanup projections. High-rate media
remains on a dedicated media plane.

## Diagnostic Escalation

Start at the lowest layer that can explain the current blocker:

1. prove route-clear preflight and absence of stale ports, sockets, or
   topology state;
2. prove control/session exchange without media;
3. send a short synthetic payload;
4. exercise one media direction;
5. exercise the full selected media shape only after lower layers are current
   and fatal-free.

Do not repeat a full media run merely because passive preflight looks clean.
Preserve the first failing layer and use the next run to test that layer
directly.

## Acceptance

A promotion evidence set should bind:

- exact source and run identities, selected provider, and the applicable
  project feature/product lock or explicit `not-selected`/`not-applicable`
  state;
- exact session and stream identities plus current revision and epoch when the
  selected contracts define them;
- provider and effect-owner instance identities where applicable;
- selected topology and current platform-network observation;
- socket owner and route;
- current app-local or selected-authority control/session/stream state, or
  explicit `not-selected`/`not-applicable` state;
- receiver-observed media counters and terminal close reason;
- decode/import counters, drops, rejects, and failures;
- final render-adoption evidence when visual presentation is claimed;
- cleanup readback for every run-owned resource;
- bounded fatal scans and explicit limitations.

Every counter, close reason, render observation, cleanup result, and fatal scan
must belong to the same current run and, when the selected contract defines
one, epoch. Reject stale or cross-run evidence instead of combining it into a
stronger claim.

Preserve a separate owner-issued receipt for every selected effect. A portable
workflow wrapper may hash-bind those receipts and state sanitized limitations;
it must not manufacture, augment, or relabel a promotion receipt.

Keep private serials, endpoint values, package identities, raw logs, captures,
and unpublished application behavior outside public source. Publish sanitized
contracts, synthetic fixtures, evidence fields, and provider-neutral lessons.

Termux or another sidecar may rehearse low-rate control, route health,
heartbeats, and evidence summaries. It does not thereby own native application
network binding, high-rate media, final render adoption, or Manifold authority.
