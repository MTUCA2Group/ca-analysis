# CRC / responsibility model – S4 Handle shortfall

Full GRASP rationale with candidates and rejected alternatives: [DR-008](../../decisions/DR-008-shortfall-responsibilities.md).

## Cards

### HandleShortfallHandler *(application layer)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| The ports it was given | Receives `viewShortfalls` and `resolveShortfall`; checks the role; loads the order and, for a substitute, the substitute's available lots; saves the order and changed lots only on success | AuditContext, Clock, Role, OrderRepository, StockLotRepository, Order |

### Order *(domain, aggregate root)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| Its lines, its customer's type, whether contact is required | Builds the `ShortfallView`; routes a resolution to the right line; decides whether the customer must be contacted (FR-10) and sets the flag; builds the `ShortfallResolutionResult` | OrderLine, ShortfallResolutionResult |

### OrderLine *(domain)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| Requested quantity, its allocations, `acceptsReducedQuantity`, `acceptsRemoval`, permitted substitutes, resolution, resolved by / at | Knows its outstanding quantity; checks the resolution is permitted (BR-05); for a substitute, allocates from the lots and creates each `Allocation`; records the resolution | StockLot, Allocation, ShortfallResolutionType |

### StockLot *(domain, reused from S1–S3)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| Accepted, held, written-off and allocated quantities | Reports `availableQuantity()`; refuses to `allocate` more than is available; orders itself by use-by (`expiresBefore`) | — |

### ShortfallResolutionType *(enum)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| `SUBSTITUTE`, `REDUCE`, `REMOVE`, `CONTACT_CUSTOMER` | — | — |

### ShortfallResolutionResult *(output DTO)*

| Knows | Does | Collaborators |
|-------|------|---------------|
| Allocations made, remaining shortfall, contact required | — (data only) | — |

## GRASP rationale

| Decision | Principle | Why |
|----------|-----------|-----|
| `HandleShortfallHandler` receives the S4 system events | Controller (use-case controller) | Same pattern as S1–S3 (DR-005); no rules in the controller |
| `OrderLine` checks the resolution against the customer's preferences | Information Expert | The line holds the preferences and the outstanding quantity (domain model: `OrderLine` permits substitutes) |
| `OrderLine` creates substitute `Allocation`s | Creator | Same as UC-05 (DR-010): allocations are recorded against the line |
| `Order` sets `contactRequired` | Information Expert | Only the order knows its customer's type; one flag per order, not per line |
| No `AllocationPolicy` class | Pure Fabrication considered and rejected | No designed operation compares competing orders (SPK-02) |