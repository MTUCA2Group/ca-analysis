# DR-012 – UC-06 restored to the selected design scope

| Field | Content |
|-------|---------|
| Date | 2026-11-27 |
| Status | Accepted |
| Owner | Philip Dawson-Gariepy |
| Decided by | Philip Dawson-Gariepy |
| Related | DR-011 (superseded), DR-003, DR-008, SPK-02, PR #17 |

## Context

DR-011 reduced the scope to three use cases because UC-06 had no work. On 27 Nov Zakary Snyder submitted a UC-06 chain (PR #17). Review against S1–S3 found it inconsistent: three different signatures for `resolveShortfall`, substitute stock fetched for the wrong product, a contract that increased lot quantities on allocation, customer preferences and the contact flag missing from the class model, and calls with no matching operations.

## Decision

Include UC-06. The chain was corrected before merging so that it agrees with the rest of the design:

- one signature, `resolveShortfall(orderLineId, resolution, substituteProductId)`, in the SSD, contract, sequence diagram and class model;
- preferences on `OrderLine` (`acceptsReducedQuantity`, `acceptsRemoval`, permitted substitutes), as in the CA1 domain model;
- contact recorded as `Order.contactRequired`;
- no `AllocationPolicy` class (SPK-02);
- GH-26 to GH-28 added for refusal, hospitality contact and permission.

`Order`, `OrderLine`, `Allocation` and `OrderRepository` move to `shared` in the integrated class diagram, matching the package view, because S3 and S4 both use them.

## Consequences

- The selected design scope is four use cases, which meets the rubric's 3–5.
- Dossier sections 1, 3 to 9, the traceability matrix, the package view and the interface catalogue were updated in the same change.
- The `ca2-submission` tag was moved to the commit that contains this change.