# Design Anti-Patterns

Full catalog of design "don'ts" from *Righting Software*. Consult this
file:
- During Phase 3 (Component Definition) as a check before finalizing
  component assignments
- During Phase 4 (Validation) when reviewing call chains
- Whenever a candidate decomposition feels wrong but you can't name why

Each entry includes the rule, why it matters, and the typical signal
that you're violating it.

## Functional decomposition (the master anti-pattern)

**The rule**: Don't decompose by what the system *does*. Components
named after verbs or use-case steps (Validate, Price, Ship, Notify,
Process, Handle) are functional decomposition.

**Why it fails**:
- Couples services to requirements
- Precludes reuse (B depends on A → C running before/after it)
- Either too many services (one per functionality) or too few god
  services
- Bloats clients with orchestration logic
- Bloats services with cross-service error compensation
- Makes regression testing impractical
- Maximizes the effect of every change

**Signals**:
- Service names are verbs or gerunds outside Engines: `BillingManager`,
  `ShippingHandler`, `PaymentProcessor`
- A single change in requirements touches 3+ services
- Clients orchestrate sequences of service calls
- Services call sideways or chain (A → B → C)
- Multiple entry points for what users perceive as one feature

**Recovery**: re-do volatility analysis. The functional names tell you
the boundaries are aligned with what the system *does*, not with what
*changes*.

## Domain decomposition (functional decomposition in disguise)

**The rule**: Don't decompose by business domain (Sales, Engineering,
Accounting, Shipping). Domain decomposition is just functional
decomposition with bigger labels.

**Why it fails**:
- Each domain devolves into a grab-bag of functionality
- Cross-domain interactions are painful → reduced to CRUD state changes
- Composite behaviors that cross domains become structurally awkward
  ("where do you do barbecue cooking in a kitchen-domain system?")
- Same flaws as functional decomp, just masked

**Signal**: components named after business areas without a volatility
axis. `Project`, `Tradesman`, `Contractor` as Managers/services →
domain decomposition.

**Recovery**: ask what *changes* about that domain — and decompose by
the axes of change, not by the domain itself.

## Speculative design

**The rule**: Don't encapsulate changes that are extremely unlikely AND
where any encapsulation would be done poorly given resources.

**Why it fails**:
- Wastes implementation effort on volatility that won't materialize
- Produces overly elaborate designs ("SCUBA-ready high heels")
- Often does poorly the very thing it's trying to enable

**Signal**:
- Components encapsulating "what if we became a different kind of
  business?"
- Encapsulation of catastrophic-but-improbable scenarios
- Long lists of candidate volatilities where most have weak evidence

**Recovery**: apply the two-question filter — (a) is the change rare?
(b) would the encapsulation be done poorly anyway? If both yes →
reject. Document the rejection in the report.

## Encapsulating the nature of the business

**The rule**: The nature of the business — what the company
fundamentally does — does not get encapsulated. It is the foundation
on which volatility-based decomposition rests.

**Why it fails**: Trying to encapsulate "what if we stopped being a
freight company and became a healthcare provider" produces designs
that are bad at being either. The cost is real; the benefit is
hypothetical.

**Note**: "Nature of the business" is fractal. It can be:
- The company's overall business
- A division or department's business
- The specific application's added value

A change at any of these levels is a *replacement*, not a refactor.

**Recovery**: identify what is genuinely permanent about this business
domain. Treat those as inputs to the design, not as components.

## The Monolith

**The rule**: Don't pile every functionality into one service.

**Signal**: One Manager (or one service) that does everything.

**Recovery**: legitimate volatility-based decomposition produces 10–20
components, not 1. If you have one, you haven't decomposed yet.

## Granular building blocks (services explosion)

**The rule**: Don't create a component for every use case activity.

**Signal**: One component per verb in the use cases. Hundreds of
fine-grained components, often with the Client orchestrating them.

**Recovery**: re-do volatility analysis. Most of those activities
aren't independently volatile.

## Skip-level calls

**The rule**: Calls go between adjacent layers only.

Forbidden:
- Client → Engine (skipping Manager)
- Client → ResourceAccess (skipping Manager and Engine)
- Manager → Resource (skipping ResourceAccess)
- Engine → Resource (skipping ResourceAccess)

**Why it fails**: Each skip imports volatility from the lower layer
into the higher one, defeating the entire point of layering.

**Recovery**: if the user demands a skip-level call for performance,
explore whether the missing layer has any volatility to encapsulate.
If not, you can fold layers together (e.g., a Manager that owns its
own ResourceAccess if there's no Access volatility), but that's a
design decision, not a violation.

## Sideways calls

**The rule**: Components in the same layer don't call each other
directly.

Forbidden:
- Manager → Manager (use queued / Pub/Sub instead)
- Engine → Engine (signals functional decomposition)
- ResourceAccess → ResourceAccess (use a single Access that joins
  Resources)

**Why each fails**:
- Manager → Manager: makes the called Manager an activity inside the
  caller's use case → they're not independent families anymore
- Engine → Engine: Engines should encapsulate everything for an
  activity; chaining means one of them isn't properly encapsulated
- Access → Access: if one atomic verb requires another, the verbs
  weren't atomic. Join the Resources in a single Access.

**Allowed alternative**: Manager → MessageBus utility → Manager
(queued). This is semantically *down* through the utility bar, not
sideways. The receiving Manager is processing a deferred new use case.

## Calling up

**The rule**: Components never call into the layer above them.

Forbidden:
- Engine → Manager
- ResourceAccess → Engine or Manager
- Resource → anything

**Why it fails**: imports the volatility of the higher layer into the
lower one — exactly backwards.

**Recovery for "I need to notify the Client when X happens"**: use a
Pub/Sub utility. The Manager publishes; the Client subscribes. Neither
calls up.

## Functional names sneaking back in

**The rule**: Component prefixes describe the volatility axis. Verbs
and use-case names belong on operations, not components.

**Bad names**:
- `OrderProcessor` — what does it process? Decomposes by use case.
- `PaymentHandler` — handles payment how? No volatility axis.
- `NotificationSender` — sender of what notifications? Functional.
- `BillingManager` — gerund prefix on a Manager. Smells functional.
- `BillingAccess` — same.

**Good names**:
- `OrderManager` — encapsulates the order workflow volatility
- `PaymentsAccess` — encapsulates the payments storage + provider
  volatility
- `Notification` (Manager) — only if there's real volatility in
  notification orchestration; otherwise a utility

## Gerund misuse

**The rule**: Gerunds (`-ing` nouns) belong only as Engine prefixes.

**Why**: Gerunds describe activities, and Engines encapsulate activity
volatility. Gerunds elsewhere signal functional decomposition.

**Good**: `CalculatingEngine`, `SearchingEngine` (or just
`SearchEngine`).

**Bad**: `BillingManager`, `MatchingAccess`.

## CRUD/IO contracts on ResourceAccess

**The rule**: ResourceAccess contracts expose atomic business verbs,
not CRUD or IO operations.

**Bad operations**:
- `Insert(record)`, `Select(criteria)`, `Update(record)`, `Delete(id)`
- `Open()`, `Close()`, `Read()`, `Write()`, `Seek(pos)`

**Why it fails**: The contract betrays the underlying technology.
Swap the DB for an in-memory hash table or a cache, and the contract
breaks; every consumer changes.

**Good operations**:
- `Credit(account, amount)`, `Debit(account, amount)`, `Pay(member,
  amount)`, `Match(criteria)`, `Reserve(item, period)`

Atomic business verbs survive Resource swaps because they describe
*what the business does*, not *how the Resource works*.

## Event-publishing violations

From the book's design "don'ts" list:

**Only Managers (and sometimes Clients via UI events) publish business
events**. Specifically forbidden:

- **Clients don't publish events**: A Client publishing means it's
  noticing state changes — that's Manager territory. With functional
  decomp the Client *is* the system and ends up needing this; that's
  the diagnosis.
- **Engines don't publish events**: An Engine has no context for *why*
  it ran. The Manager has the context and should publish.
- **ResourceAccess doesn't publish events**: same reason.
- **Resources don't publish events**: business logic in a Resource is a
  hallmark of functional decomp.

## Event-subscription violations

**Only Clients and Managers subscribe to events**. Specifically
forbidden:

- **Engines don't subscribe to events**: events trigger use cases;
  Engines don't run use cases.
- **ResourceAccess doesn't subscribe**: same.
- **Resources don't subscribe**: same.

If an Engine needs to "react" to something, the Manager owning the
relevant workflow should subscribe and call the Engine in response.

## Queue / asynchronous violations

**Only Managers receive queued calls.**

- **Engines don't receive queued calls**: Engines exist to execute
  volatile activities for Managers. A queued call to an Engine
  executes "the activity" detached from any use case — meaningless.
- **ResourceAccess doesn't receive queued calls**: same — accessing a
  resource detached from any business logic isn't a use case.

**Managers don't queue calls to more than one Manager in the same use
case.** If two Managers need to react to a state change, why not all of
them? Use Pub/Sub instead of fan-out queuing.

## Clients calling multiple Managers in one use case

**The rule**: A single Client use case touches exactly one Manager.

**Why it fails**: If a Client needs Manager A *then* Manager B to
complete a use case, the Client is orchestrating — i.e., the Client
has business logic. That's functional decomposition with extra steps.

**Recovery**: introduce a higher-level Manager that owns the
cross-Manager workflow, OR use queued Manager-to-Manager via Pub/Sub,
OR re-examine whether A and B are really separate Manager-worthy
families of use cases.

## Resisting the siren song

**The rule**: Don't add components out of habit. If something isn't
volatile, it doesn't deserve a component.

**Common temptations**:
- Adding a "Reporting" component because every system you've built had
  one
- Adding a "Validation" component because validation logic exists
- Adding an "Orchestration" service because "we need a place to
  orchestrate"

**Recovery**: ask "what's the volatility axis this encapsulates?"
If you can't name one, the component is functional. Bind yourself to
the mast and don't add it.

## Layer-based decomposition pretending to be volatility-based

**The rule**: API / BLL / DAL is layering by technical concern, not by
volatility.

**Signal**: Components named after layer abstractions (`OrderApi`,
`OrderBll`, `OrderDal`) without a volatility axis.

**Recovery**: each iDesign layer (Client / Manager / Engine /
ResourceAccess) encapsulates a different *kind* of volatility.
Naming components after their layer alone says nothing about what
they encapsulate.

## Fat Managers

**The rule**: Managers orchestrate. They do not contain business logic.

**Signal**: Manager code does calculations, applies rules, transforms
data.

**Recovery**: extract the logic into an Engine. The Manager should
read like a workflow definition: call this Engine, then that Access,
then publish this event.

## Anemic Engines

**The rule**: Engines exist to encapsulate genuine activity volatility.

**Signal**: An Engine that just forwards a call to a ResourceAccess.

**Recovery**: if there's no real logic in the Engine, the Engine is
fictitious. Have the Manager call ResourceAccess directly (allowed
when there's no activity volatility to encapsulate).

## Shared mutable databases

**The rule**: Services don't share a database.

**Signal**: Two components write to the same table in the same
Resource.

**Why it fails**: services that share a database are coupled through
the schema. Schema change ripples across the supposedly-decoupled
services.

**Recovery**: each Resource has exactly one Access. If two parts of
the system seem to need the same data, route both through the same
Access. Don't bypass it.

## Interface churn

**The rule**: Component interfaces are the stable contract. The
implementation behind them absorbs change.

**Signal**: interfaces change as often as implementations. Component
contracts get versioned every release.

**Diagnosis**: either the wrong axis of volatility was encapsulated, or
the contract leaks implementation details (e.g., CRUD in a
ResourceAccess contract).

**Recovery**: re-examine what the component encapsulates. The contract
should expose the *invariant* — atomic business verbs, workflow names,
events. The volatile part lives inside.
