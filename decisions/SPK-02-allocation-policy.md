# SPK-02 – Shortage priority behind an AllocationPolicy?

| Field | Content |
|-------|---------|
| Date | 2026-11-27 |
| Status | Accepted |
| Owner | Zakary Snyder |
| Reviewer | Philip Dawson-Gariepy |
| Related | RC-02, A-05, Q-05, US-03, US-04, UC-05, UC-06, FR-08, FR-10 |

## Question

When there is not enough stock for every order, how should stock be prioritised, and does the CA2 design need an `AllocationPolicy` class to hold that rule?

## Evidence

- CA1: priority was first come, first served (A-05), but the hub has not confirmed it (Q-05).
- RC-02: the priority rule may change, so it should not be hard-coded.
- UC-05: staff choose which order to allocate; each allocation takes what is available and reports the shortfall.
- US-03, US-04: a substitution or reduction must never be assumed; the customer's recorded preference decides.

## Options

| Option | Advantages | Disadvantages |
|--------|-----------|---------------|
| A. First come, first served, by the order in which staff allocate | Simple, transparent, testable; needs no new class | Cannot favour particular customers |
| B. Manual staff choice per conflict | Flexible | Inconsistent between staff |
| C. Design a full prioritisation policy now | Precise | No rules confirmed; nothing to design against |

## Result

**Option A.** Stock goes to orders in the order staff allocate them (UC-05), and UC-06 resolves each remaining shortfall by the customer's own preferences. No designed operation compares two competing orders, so the CA2 design does **not** introduce an `AllocationPolicy` class: it would have one implementation and no caller.

## Consequences

- RC-02 stays open and is recorded as a limitation in the design evaluation.
- If the hub confirms a priority rule, it would be added as an `AllocationPolicy` port used by `AllocateStockHandler` to order the orders it allocates; `OrderLine` and `StockLot` would not change.
