# Volatility Discovery Techniques

Supplementary techniques for Phase 2 (Volatility Analysis). Consult this
file when the candidate volatility list feels thin, when the user is
stuck, or when symmetry/composability gaps in Phase 4 suggest a missing
axis of change.

## The anti-design effort

**When to use**: When the team (or the user) is anchored on functional
decomposition and won't release the grip.

**The technique**: Pose a design contest. Split the team in half — one
group designs "the best system for these requirements", the other
designs "the worst possible system: one that maximizes inability to
extend, disallows reuse, makes maintenance maximally expensive". Let
them work in separate rooms for an afternoon.

**The reveal**: When they compare results, both groups will almost
always have produced **the same design**. The labels differ; the
essence is identical. Then disclose that they weren't working on the
same problem and discuss the implication: their "best" design is just
their habitual one, and the habit is functional decomposition.

In a one-on-one interview, you can do a one-person version: have the
user describe what a deliberately *bad* version of their system would
look like, then compare to their candidate good design. If they're
similar, that's the diagnosis.

## Design factoring iterations

A useful way to walk a user from a candidate monolith to a proper
decomposition without lecturing.

**Iteration A**: Start with one big "System" box.

> "Could you use this one component, as-is, for the same customer
> forever, with no changes?"

If no → ask why. Whatever they name, encapsulate it.

**Iteration B**: Now you have System + ChangeBox1.

> "Could you use this two-component design across all your customers
> right now?"

If no → ask what differs. Encapsulate that.

**Iteration C**: System + ChangeBox1 + ChangeBox2.

Continue until both axes of volatility (customer-over-time and
customers-at-same-time) are saturated. The resulting boxes are
candidate volatilities.

This is mechanical, low-pressure, and surprisingly effective at
surfacing volatilities the user didn't volunteer in a free-form
interview.

## Design for your competitors

**The question**: *"Could your direct competitor use this system as-is?
If not, where would they need it to behave differently?"*

**Variants**:
- *"If your company merged with [competitor], what would have to change
  in this system to support both businesses?"*
- *"If you were building this for a different division of your own
  company (e.g., regional / enterprise / SMB), what would need to
  flex?"*
- *"Where does your current system have a hardcoded assumption that
  reflects your business but not the industry?"*

**Interpreting the answer**:
- Differences they name → **candidate volatilities** (because if two
  ways exist, more might)
- Aspects they say are identical across all competitors → **nature of
  the business** (don't encapsulate)

## The longevity heuristic

**The premise**: An organization's *rate* of change tends to be roughly
constant, because it's tied to the nature of the business. A hospital
IT department changes things slowly; a fintech startup changes them
weekly. Both have a *steady* cadence.

**The technique**:
1. Ask the projected lifespan of the new system: 3 years? 5? 10?
2. Look back the same number of years in the application domain
3. Whatever changed in that window is likely to change again in a
   similar window

**Example**: If the ERP system changes every 10 years, the last change
was 8 years ago, and the new system's horizon is 5 years → the ERP
will almost certainly change during this system's lifetime. Encapsulate
that integration, even if it wasn't on the explicit requirements list.

This is the technique most likely to surface volatility the user
*genuinely* didn't know to volunteer. It produces architectural concerns
out of historical pattern matching rather than current opinion.

## The Brexit test (unexpected change)

**Source**: The TradeMe case study from the book.

The TradeMe design was completed *before* Brexit. The system was meant
to operate across EU locales. When Brexit happened — a change nobody
predicted — the architecture absorbed it cleanly because the
**RegulationEngine** encapsulated regulatory volatility regardless of
the political cause.

**The interview move**: *"Name a change that hit your last system out
of nowhere — a regulatory shift, a partner going under, a sudden
re-org, a discontinued service. Was that something the old
architecture could absorb cleanly, or was it a rewrite?"*

Past surprises are excellent evidence of axes that need encapsulation —
not because the same surprise will recur, but because the **kind** of
surprise will.

## Solutions masquerading — the recursive peel

When the user states a requirement, ask whether it's a *solution* to
something deeper.

**Mechanical pattern**:
1. User states: "The system should send an email confirmation."
2. Ask: "What's that email actually accomplishing for the business?"
3. User: "Letting them know the order went through."
4. Ask: "Could the same need be served by SMS, push notification,
   webhook, or paper letter?"
5. User: "Sure, some customers want SMS."
6. **Real volatility**: notification transport.

**Peel deeper when possible**:
- "Cook the meal" → "Feed the occupants" → "Occupants' well-being"
- "Calculate tax" → "Comply with regulations" → "Avoid penalties + maintain license"

Sometimes peeling reveals **two volatilities** at different levels:
- Notification transport (Engine-level)
- Notification subscribers / who receives what (Manager-level)

Both may need encapsulation in different layers.

## Proactive candidate proposals (Claude's domain knowledge)

When the user's candidate list is thin, propose volatilities from
common patterns in their system's domain. Don't just ask — *offer*.

### Common volatility patterns by domain

**Payment / financial systems**:
- Payment method / provider
- Currency + FX rate sourcing
- Regulatory regime (PCI, AML/KYC, regional tax)
- Fraud detection algorithm
- Reconciliation cadence and source-of-truth

**Marketplace / matching systems** (per TradeMe):
- Member type / role volatility
- Search / matching algorithm
- Pricing and fee structure
- Notification transport
- Disputes and reversals
- Regulation and compliance (per locale)

**Logistics / fulfillment**:
- Carrier / shipping partner
- Route optimization
- Rate calculation
- Tracking event sources
- Locale-specific customs / regulations

**SaaS / multi-tenant**:
- Tenant onboarding / billing model
- Identity provider / SSO
- Per-tenant feature flags
- Audit / compliance regime
- Data residency / regional deployment

**Healthcare / regulated**:
- Coding standards (ICD, CPT, SNOMED)
- Compliance regime (HIPAA, GDPR, etc.)
- Identity verification
- Interfacing standards (HL7, FHIR)
- Reporting requirements

**Always frame the proposal as a question**:

> "In most marketplaces I've seen, disputes between buyer and seller
> eventually become an architectural concern — they touch member
> records, payment reversals, and often regulatory reporting. Does
> that apply here, or do you have a different mechanism in mind?"

Don't dump the whole list — pick 2–4 candidates that fit the user's
described system and offer them via `AskUserQuestion` if helpful.

## The "tip of the iceberg" probe

From the book: *"the users interact with or observe just a small part
of the system, which represents the tip of the iceberg. The bulk of
the system remains below the waterline."*

If the user has named only Client-facing use cases, push below the
waterline:

- **Schedulers / timers** — what runs at midnight? At end of month? On a
  cron?
- **Reconciliation** — when does the system check itself against an
  external source of truth?
- **Backfill / catch-up** — when state was lost or a partner was down,
  what runs to recover?
- **Reporting** — who pulls data out, when, in what format?
- **Audit** — what events are recorded for compliance, even if no user
  ever sees them?
- **Health / monitoring** — what does the system emit so operators can
  see it working?
- **Admin / operator** — what do internal users do that customers
  don't?
- **External-system callbacks** — webhooks, partner ACKs, retries

Most of these surface volatility the user didn't think to mention.

## When to stop discovering

You can keep peeling and probing forever. Stop when:
- Most new candidates the user (or you) propose get rejected as
  variable / speculative / nature-of-business
- The accept-list is stable across two rounds of probing
- The user is visibly tired of the exercise

A well-discovered Volatilities List usually has 5–12 surviving
candidates. Fewer suggests under-discovery; more suggests
over-encapsulation (speculative design risk).
