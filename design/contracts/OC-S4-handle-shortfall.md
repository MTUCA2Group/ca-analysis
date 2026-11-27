# Operation contracts – S4 Handle shortfall

`viewShortfalls(orderId)` only reads data and has no contract. Errors follow the interface catalogue §3; the actor's identity and role come from `AuditContext`, the time from `Clock`.

## OC-07 resolveShortfall

| Field | Content |
|-------|---------|
| **Operation** | `resolveShortfall(orderLineId: OrderLineId, resolution: ShortfallResolutionType, substituteProductId: ProductId?): Result<ShortfallResolutionResult>` |
| **Cross-references** | UC-06 steps 3–8, extensions 1a, 3a, 3b, 4a, 4b, 5a, 5b · GH-23 to GH-28 · FR-08, FR-10 · BR-05 · NFR-04, NFR-05 · A-12, A-13 |
| **Preconditions** | The order line exists and its outstanding quantity (requested − allocated) is greater than zero, and it has no recorded resolution. |
| **Postconditions – all resolutions** | `ol.resolution` = `resolution`; `ol.resolvedBy` was associated with the current user; `ol.resolvedAt` = `Clock.now()`. If, after the resolution, the line's allocated quantity is below its requested quantity and the order's customer type is `HOSPITALITY`, or the resolution is `CONTACT_CUSTOMER`, then `order.contactRequired` became true (FR-10). |
| **Postconditions – SUBSTITUTE** | For each available lot of the substitute product used, earliest use-by first, while the line is still short: an `Allocation` instance `a` was created; `a` was associated with `ol` and with the lot; `a.quantity` = the smaller of the line's outstanding quantity and the lot's available quantity; `lot.allocatedQuantity` increased by `a.quantity`, so the lot's available quantity fell by the same amount (NFR-04). If too little stock is available, the remaining quantity stays outstanding (extension 5a). |
| **Postconditions – REDUCE** | No allocation was created. The line's outstanding quantity is treated as 0: the customer accepted the quantity already allocated. |
| **Postconditions – REMOVE** | No allocation was created. The line's outstanding quantity is treated as 0 and the line is excluded from delivery. |
| **Postconditions – CONTACT_CUSTOMER** | No allocation was created. The shortfall stays outstanding until the customer has been contacted. |
| **Controlled failures** | `NOT_FOUND` – order line does not exist · `NOT_PERMITTED` – actor is a volunteer (A-13); `SUBSTITUTE` with a product the line does not permit or with no product named; `REDUCE` when `acceptsReducedQuantity` is false; `REMOVE` when `acceptsRemoval` is false (BR-05) · `INVALID_STATE` – no outstanding quantity; a resolution is already recorded; `REMOVE` on a line that already has allocations |
| **Invariant checked** | BR-05: every allocation on the line is for its own product or a permitted substitute. NFR-04: for every lot, `allocatedQuantity ≤ acceptedQuantity`. |

## Notes

- The contact flag is recorded; sending the message is outside CA2.
- A failure creates no allocation and changes no quantity, resolution or flag.