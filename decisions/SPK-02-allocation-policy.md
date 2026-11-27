# SPK-02 – Shortage Priority Behind an AllocationPolicy?


| Field | Content |
|---|---|
| Date | 2026-11-24 |
| Status | Proposed |
| Owner | Zakary Snyder |
| Reviewer | Not specified |
| Related | RC-02, A-05, Q-05, US-03, US-04, UC-05, UC-06, FR-08, FR-10 |

## Question

When there is insufficient stock available to fill all orders, how should stock be prioritised until a proper system is set in place?

## Evidence

- CA1: Priority was based on first-come-first-serve principle, but specific rules are unconfirmed.
- RC-02: Priority sits behind an `AllocationPolicy`, and the rule can change.
- UC-05: Orders are selected by staff who report remaining shortfalls.
- US-03: Customer choice must be prioritised during stock shortages.
- US-04: Product substitution or quantity reduction must not be assumed; recorded approval must be obtained from the customer.

## Options

| Option | Advantages | Disadvantages |
|---|---|---|
| First-come-first-serve | Basic, cheap, easy, transparent, simple to test and implement. | Fails to accommodate more valued customers or any prioritisation rules whatsoever. |
| Manual staff choice | Flexible. | Inconsistent. |
| Immediately design a detailed prioritisation system | Precise. | No rules currently confirmed; insufficient time. |

## Result

**Option A is recommended:** handle stock shortfalls by assigning products to orders on a first-come-first-serve basis until a proper prioritisation system can be developed. Initially, prioritise whoever submits their order first, with customers unable to order more than is in stock, and receive an alert if an order made since loading stock information drops total stock below the order, asking them to choose a different amount.

## Consequences

- RC-02 still has no confirmed policy.
- S3's allocation design will use `AllocationPolicy` instead of a hard-coded priority designation process.
- The transitional `AllocationPolicy` will be first-come-first-serve.
- A rule must be established in the case of two conflicting orders made at the same millisecond.
