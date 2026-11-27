# UC-06 – Handle Shortfall

| Field | Content |
|---|---|
| ID / slice | UC-06 S4 Handle Shortfall |
| User Stories | US-03 Respect Substitution Preferences & US-04 Warn Hospitality Customers Early |
| Scope | Kerry Local Food Hub Stock and Order System |
| Level | User Goal |
| Primary Actor | Hub Staff Member / Manager |
| Stakeholders and Interests | Customers only receive products and quantities they have approved. Hospitality customers are notified of shortfalls early to enact contingencies. Hub staff manage shortfalls by following customer preferences. Hub manager prevents overallocation of stock for substitutions. |
| Trigger | S3 places an order causing a shortfall. |
| Preconditions | Actor is identified and has a role (NFR-05). An order exists with at least one order line (FR-07, UC-04). The order line contains a requested quantity greater than the quantity of that product in stock. Customer shortfall preferences are recorded. |
| Success Guarantee | The shortfall is resolved based on customer preferences. No unpermitted substitute is allocated. The order line is adjusted to reflect the shortfall. Hospitality customers are flagged for contact if their quantities are reduced. |
| Minimal Guarantee | If the shortfall cannot be resolved, no unpermitted substitute or quantity is allocated. Existing allocations are unchanged. The shortfall is visible and the customer is flagged for contact. |
| Requirements and Rules | US-03, US-04, FR-08, FR-10, BR-05, RC-02, NFR-04, NFR-05 |
| Gherkin | GH-23 to GH-25 in `Handle_Shortfall.feature`. |

## Main Success Scenario

1. The staff member selects an open order.
2. The system shows the order's lines, each with the requested quantity and the product's available quantity.
3. The requested quantity is greater than the product's available quantity.
4. The staff member asks the system to resolve the shortfall.
5. The system considers available stock to replace the requested product.
6. The system allocates replacement stock where permitted according to the customer's preferences.
7. The order's line is updated along with any remaining shortfall.
8. If a shortfall remains, the customer is flagged for contact before delivery.

## Extensions

- **1a. Order line does not exist:** The system refuses (`NOT_FOUND`).
- **4a. Order line has no shortfall:** The system refuses (`INVALID_STATE`).
- **6a. Customer preferences not recorded:** The system cannot resolve the shortfall.
- **6b. Customer refuses reduced quantity:** The system must not allocate a reduced quantity.
- **6c. Substitute is not permitted:** The system refuses (`NOT_PERMITTED`).

## Special Requirements

- BR-05: Only permitted substitutes may be allocated.
- FR-08: The system must follow customer preferences.
- FR-10: Hospitality customers must be flagged for contact when supply is reduced.
- NFR-04: Allocations cannot exceed stock.
- NFR-05: The staff member responsible for allocations and shortfall resolutions is recorded along with the time.

## Open Issues

- **Allocation Policy:** Confirm how `AllocationPolicy` is implemented when customers compete for stock.
- **Customer Notifications:** The system flags customers for contact. This is currently outside this use case.

## Acceptance Criteria

| Criterion | Covered by |
|---|---|
| AC-03.1 Order lines can list zero or more potential substitutes. | GH-23 |
| AC-03.2 Unpermitted substitutes must not be allocated. | GH-24, GH-23 |
| AC-04.1 Order lines under-filled display the shortfall. | GH-24, GH-25 |
| AC-04.2 Hospitality customers are flagged for contact before deliveries. | GH-03 |
| BR-05 Substitutions follow customer preferences. | GH-23, GH-24 |
| NFR-04 Allocations must not exceed quantities available. | GH-25 |
