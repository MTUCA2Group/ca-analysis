# UC-06 Handle shortfall (fully dressed)

| Field | Content |
|-------|---------|
| **ID / slice** | UC-06 · S4 Handle shortfall |
| **User stories** | US-03 Respect substitution preferences; US-04 Warn hospitality customers early (`requirements/backlog.md`) |
| **Scope** | Kerry Local Food Hub Stock and Order System |
| **Level** | User goal |
| **Primary actor** | Hub staff member (also hub manager by generalisation) |
| **Stakeholders and interests** | Customers: receive only quantities and substitutes they have agreed to (E-05, BR-05). Hospitality customers: hear about shortfalls early so they can change menus (E-06). Hub staff: resolve shortfalls by following recorded preferences instead of guessing. Hub manager: substitutes never over-allocate stock (NFR-04). |
| **Trigger** | UC-05 has allocated an order line and reported a shortfall. |
| **Preconditions** | The actor is identified and has a role (NFR-05). The order exists and at least one of its lines has an outstanding shortfall. Each order line records whether the customer accepts a reduced quantity, accepts removal, and which substitute products are permitted (FR-08). |
| **Success guarantee** | The line's resolution, the user and the time are recorded. Any substitute allocated is a permitted product and draws only on available stock. The order is flagged for contact when the customer must be told before delivery (FR-10). |
| **Minimal guarantee** | No substitute or reduction the customer has not agreed to is applied. Existing allocations are unchanged. A refused request changes nothing. |
| **Requirements / rules** | FR-08, FR-10 · BR-05 · NFR-04, NFR-05 · RC-02 · A-12, A-13 |
| **Gherkin** | GH-23 to GH-28 (`features/handle_shortfall.feature`) |

## Main success scenario

1. The staff member selects an order with shortfalls.
2. The system shows each short line with its requested, allocated and outstanding quantity, and the customer's recorded preferences.
3. The staff member chooses a resolution for one line: substitute (naming a permitted product), reduce, remove, or contact the customer.
4. The system checks that the customer's recorded preferences permit the resolution (BR-05, FR-08).
5. For a substitute, the system allocates available stock of the substitute product, earliest use-by first, up to the outstanding quantity (NFR-04).
6. The system records the resolution with user and time (NFR-05).
7. If the line stays below its requested quantity for a hospitality customer, or the resolution is to contact the customer, the system flags the order for contact before delivery (FR-10).
8. The system shows the result: allocations made, remaining shortfall and whether contact is required.

Steps 3–8 repeat for each short line.

## Extensions

- **1a. The actor is a volunteer (A-13):** the system refuses (`NOT_PERMITTED`).
- **1b. The order does not exist:** the system refuses (`NOT_FOUND`).
- **3a. The order line does not exist:** the system refuses (`NOT_FOUND`).
- **3b. The line has no outstanding shortfall, or was already resolved:** the system refuses (`INVALID_STATE`).
- **4a. The preferences do not permit the resolution** (the substitute is not listed, or a reduction or removal is not accepted): the system refuses (`NOT_PERMITTED`) and nothing changes. The staff member chooses another resolution; contacting the customer is always permitted.
- **4b. No preferences are recorded:** only "contact the customer" is permitted (follows from 4a).
- **5a. The substitute has less available stock than the outstanding quantity, or none:** the system allocates what is available; the rest stays as shortfall. This is a success, as in UC-05.
- **5b. Removal is chosen but the line already has allocations:** the system refuses (`INVALID_STATE`); the staff member chooses "reduce" instead.

## Assumptions

- **A-12** A substitute is sold in the same selling unit as the product it replaces and counts one-for-one against the shortfall.
- **A-13** Volunteers may not resolve shortfalls, as in UC-05 (to confirm, Q-04).

## Open issues

- RC-02: priority between orders competing for the same stock is not designed (SPK-02).
- Contacting the customer is recorded as a flag; sending the message is outside this use case.

## Acceptance criteria → Gherkin

| Criterion | Covered by |
|-----------|------------|
| AC-03.1 Each order line can list zero or more permitted substitutes | GH-23, GH-24 |
| AC-03.2 A substitute that is not permitted cannot be allocated | GH-26 |
| AC-04.1 A line allocated below its requested quantity shows the shortfall | GH-24, GH-25 |
| AC-04.2 The customer is flagged for contact before the delivery date | GH-27 |
| NFR-04 Allocations never exceed available stock | GH-25 |