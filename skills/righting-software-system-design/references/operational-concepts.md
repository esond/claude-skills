# Operational Concepts (Optional Advanced Patterns)

These are run-time patterns from the TradeMe case study (Chapter 5 of
*Righting Software*) that can be layered on top of a volatility-based
decomposition. **They are optional.**

**Default position**: do NOT recommend any of these. Volatility-based
decomposition stands on its own with direct synchronous calls between
layers. Recommend an operational concept only when the Phase 0
objectives specifically require it AND the team has the maturity to
implement it.

Löwy is explicit: *"calibrate the architecture to the capability and
maturity of the developers and management. After all, it is a lot
easier to morph the architecture than it is to bend the organization."*

## When each pattern is justified

| Pattern | Justified when the Phase 0 objectives include |
|---------|-----------------------------------------------|
| **Message Bus** | "High throughput", "extensibility", "loose coupling between Clients and back-end", "support N:M event distribution", "must accommodate disconnected Clients" |
| **Message Is The Application** | "Forward-looking integration", "must support undefined future use cases without architectural change", "needs to integrate with many external systems over time" |
| **Workflow Managers** | "Quick turnaround for new features without redeployment", "deep customization across markets/locales", "business or product owners need to edit workflows directly", "long-running workflows spanning sessions/devices/days" |

If none of these are in Phase 0, default to: synchronous calls,
in-Manager workflow code, direct ResourceAccess from Managers.

## Message Bus

### What it is

A Message Bus is a queued Pub/Sub utility. Any message posted is
broadcast to N subscribers; if the bus or subscribers are down,
messages queue and process when connectivity is restored.

### How it changes the architecture

- All Client-to-Manager and Manager-to-Manager calls go through the bus
- Decouples publishers from subscribers along the timeline
- Provides N:M communication without point-to-point coupling
- Enables high throughput (queues absorb spikes)
- Survives disconnected clients (mobile, intermittent partners)

### Required features (from the book)

A real Message Bus must support:
- Queuing, multicast, broadcast
- Headers and context propagation
- Both posting and retrieving secured
- Off-line / disconnected work
- Delivery failure handling
- Poison message handling
- Transactional processing
- High throughput
- Service-layer API
- Multiple protocol support (not just HTTP)
- Reliable messaging

Nice-to-haves: filtering, inspection, custom interception,
instrumentation, automated deployment, remote configuration.

### Tradeoffs

- **Adds**: complexity, moving parts, new APIs to learn, deployment
  burden, intricate failure scenarios
- **Buys**: decoupling, extensibility, throughput, asynchronous /
  disconnected support

### When to recommend

Recommend only when the Phase 0 objectives explicitly require what the
bus buys. Don't add it for theoretical flexibility — the complexity tax
is real.

**Starter advice from the book**: pick a plain, easy-to-use, free
Message Bus first; implement the architecture against it; learn what
features matter for your case; *then* select a best-of-breed.

### Constraints even with a Message Bus

Adding a bus does not eliminate architectural rules:
- Clients still can't talk to Clients across the bus
- Engines, ResourceAccess, and Resources still don't publish events
- Engines and ResourceAccess still don't receive queued calls
- The bus is a Utility, not an excuse to open up the architecture

## The Message Is The Application pattern

### What it is

An evolution of the Message Bus pattern. Instead of services
explicitly calling each other (even through a bus), the **application
itself disappears**: services subscribe to messages, do local work,
and post new (or modified) messages back. The "application" is the
aggregate of message transformations across services.

### When it's justified

- Forward-looking design: nothing in the system ties to current
  requirements
- Extensibility by addition: new behavior = new subscriber, no changes
  to existing services
- Integration with external systems as a first-class concern
- Eventually approaches an actor model

### Why most projects shouldn't use it

The pattern stretches decoupling almost to a limit. Required behavior
is *emergent* from message progression, not localized in any service.
This is hard to:
- Debug (no central orchestration to trace through)
- Test (combinatorial state explosions)
- Reason about (no single component "owns" any feature)

Recommend only when:
- The business case (per Phase 0) genuinely justifies the cost
- The team has prior experience with event-driven / actor systems
- There's organizational backing to maintain the discipline

Otherwise, default to direct synchronous calls between layers and let
the team grow into this pattern later.

## Workflow Managers

### What it is

A Manager that doesn't hardcode its workflow. Instead, the workflow is
stored externally (e.g., in a workflow engine product), loaded by
instance for each call, executed, and persisted back.

### Mechanics

For each call, the workflow Manager:
1. Receives a request with a workflow instance ID
2. Loads the appropriate workflow type AND specific instance with its
   state/context
3. Executes the next step
4. Persists the instance back to the workflow store

This supports long-running workflows: each call can come from a
different device / session / day, carrying only the instance ID. The
Manager itself stays stateless.

### When it's justified

- **High volatility in business workflows**: the workflow changes
  faster than the dev team can ship code changes through normal
  release cycles
- **Deep per-tenant / per-locale customization** that would require
  proliferating Manager subclasses or feature flags
- **Long-running workflows** spanning sessions, devices, or days
- **Need for product owners or end users to edit workflows directly**
  (with appropriate safeguards)

### Required workflow tool features

- Visual editing of workflows
- Persist + rehydrate workflow instances
- Call services from within workflows across multiple protocols
- Post messages to the Message Bus
- Expose workflows as services across multiple protocols
- Nesting workflows
- Library of reusable workflow patterns
- Debug / playback / instrumentation

### When not to use

If the team would simply hand-code workflow code in the Manager and
deploy via normal CI/CD with acceptable speed, the additional tool +
storage + learning curve isn't worth it. Hand-coded Manager workflow
is the default; workflow Managers are the optimization.

## Combining patterns

The TradeMe case study uses **all three together**:
- Message Bus for all Client-to-Manager and Manager-to-Manager
  communication
- Message-Is-The-Application as the operational model
- Workflow Managers for every Manager

This is a high-bar configuration. Löwy is explicit that it's
justified for TradeMe because *all seven* of the Phase 0 objectives
called for it — unify repos, quick turnaround, deep customization,
visibility, forward-looking, integration, streamlined security.

For most systems, choose the pattern(s) that match the Phase 0
objectives and skip the rest.

## How to write this into the report

If recommending any of these patterns, add an `## Operational Concepts`
section to `report.md` with:

1. **Which pattern(s)** you're recommending
2. **Which Phase 0 objectives** justify each one (cite specifically)
3. **Tradeoffs accepted** — explicit acknowledgment of the complexity
   tax
4. **Prerequisites** — team experience, tooling, organizational
   support
5. **Phasing** — if the team isn't ready today, when does it become
   warranted?

If NOT recommending any, **say so explicitly** in the report. A
silent omission gets re-litigated later; an explicit "we considered
and rejected X because Y" closes the question.
