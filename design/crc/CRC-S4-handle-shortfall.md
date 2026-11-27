# CRC S4 Handle Shortfall

## Cards

### HandleShortfallHandler (application layer)

| Knows | Does | Collaborators |
|---|---|---|
| The ports it was given | Receives the S4 system events. Performs permission checks. Loads relevant order and stock lots. Orchestrates shortfall resolutions. Saves altered order and stock lots. Returns `Result<T>`. | AuditContext, Clock, OrderRepository, StockLotRepository, Role, Order, AllocationPolicy |

### AllocationPolicy (domain)

| Knows | Does | Collaborators |
|---|---|---|
| The priority rules it covers | Defines the priority rule used regarding allocation decisions. Allows it to replace the temporary allocation policy without modifying shortfall handling. | Order, TemporaryAllocationPolicy |

### TemporaryAllocationPolicy (domain)

| Knows | Does | Collaborators |
|---|---|---|
| SPK-02 temporary AllocationPolicy | Prioritises order by date-time. | Order, AllocationPolicy |

### ShortfallResolutionResult (output DTO)

| Knows | Does | Collaborators |
|---|---|---|
| Result of shortfall resolution, total allocations, shortfall remaining, resolved lines, required contact | Returns the shortfall-resolution outcome to the handler. | HandleShortfallHandler, OrderLine, Allocation |

## GRASP Reasoning

| Decision | Principle | Why |
|---|---|---|
| HandleShortfallHandler orchestrates system event | Controller | Separates system event-handling from domain rules. |
| AllocationPolicy hides allocation priority | Encapsulation | Allows it to replace temporary policy without rewriting handlers. |
| TemporaryAllocationPolicy implements abstraction | Polymorphism | Allows AllocationPolicy child classes to replace temporary prioritisation rules. |
