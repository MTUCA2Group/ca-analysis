# DR-008 – Responsibilities for resolving a shortfall

| Field | Content |
|-------|---------|
| Date | 2026-11-27 |
| Status | Accepted |
| Owner | Zakary Snyder |
| Reviewer | Philip Dawson-Gariepy |
| Related | UC-06, OC-07, CRC-S4, SD-S4, SPK-02, DR-010 |

## Context

OC-07 requires a chosen resolution to be checked against the customer's recorded preferences (BR-05), substitute stock to be allocated without over-allocating (NFR-04), and the customer to be flagged for contact when needed (FR-10). Someone must own each of these.

## Candidates

| Candidate | For | Against |
|-----------|-----|---------|
| `HandleShortfallHandler` checks preferences and flags contact | Everything in one place | Business rules in the controller; another caller could bypass BR-05 |
| A separate `ShortfallPolicy` / `AllocationPolicy` object | Could vary the rule later | No variation exists yet; adds a class with one implementation (SPK-02) |
| **`OrderLine` checks and applies the resolution; `Order` decides contact** | Each holds the data its rule needs | `OrderLine` grows by four small operations |

## Decision

`OrderLine.resolve(...)` checks that the resolution is permitted, allocates substitute stock and records the resolution. `Order.resolveShortfall(...)` routes to the line and, from the line's result and its own customer type, decides whether to set `contactRequired`.

## Principle

Information Expert (the line holds the preferences and outstanding quantity; the order holds the customer type), Creator for substitute `Allocation`s (as in DR-010), Controller for the handler.

## Rejected alternatives

- The handler checking `acceptsReducedQuantity` and the substitute list: BR-05 would live outside the domain.
- One strategy class per resolution type (Polymorphism): four short branches do not justify four classes; we would introduce it only if resolutions gained their own rules.

## Consequences

- `OrderLine` and `Order` gain S4 operations in the integrated class diagram; S3's allocation operations are unchanged.
- Substitute allocation reuses `StockLot.allocate`, `availableQuantity` and `expiresBefore`, so NFR-04 is enforced in the same place for UC-05 and UC-06.