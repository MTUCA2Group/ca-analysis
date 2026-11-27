# Operation Contract – S4 Handle Shortfall

| Field | Content |
|---|---|
| **Operation** | `resolveShortfall(orderLineId: OrderLineId, resolution: ShortfallResolutionType, substituteProductId: ProductId?): Result<ShortfallResolutionResult>` |
| **Cross-references** | UC-06, GH-23, GH-24, GH-25, FR-08, FR-10, BR-05, NFR-04, NFR-05, RC-02 |
| **Preconditions** | Actor is identified and has a role. Order line exists and has an unresolved shortfall. |
| **Postconditions – Reduced Quantity** | A `ShortfallResolution` archives accepted reduction, quantity, staff member and date-time. Existing allocations remain unchanged. Accepted shortfall is resolved. Contact-required flag is applied when needed. |
| **Postconditions – Removal** | A `ShortfallResolution` archives removed quantity, staff member and date-time. No substitute is allocated. Contact-required flag is applied when needed. |
| **Postconditions – Substitute** | Substitute products are permitted by customer preference. Substitute allocations are linked to their order line and source lot. Lots' quantities increase by the quantity allocated. The `ShortfallResolution` archives the substituted product, its quantity, the quantity resolved, staff member and date-time. The handler builds `ShortfallResolutionResult` and returns remaining shortfall. Contact-required flag is applied when needed. |
| **Returns** | Resolution result, substitute allocations, resolved quantities, unresolved shortfalls and contact flags. |
| **Controlled Failures** | `NOT_FOUND` – order line not found; `NOT_PERMITTED` – role is volunteer or resolution options not permitted by customer preferences; `INVALID_STATE` – no shortfall or shortfall already resolved. |
| **Invariant Checked** | BR-05: only permitted substitutions are allocated. NFR-04: quantity allocated must not exceed available stock. NFR-05: both allocation and resolution record user and time. |

## Notes

- Contact flags are recorded; notifications are not sent.