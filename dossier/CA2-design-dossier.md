# CA2 Design Dossier – Kerry Local Food Hub

**Module:** Object-Oriented Analysis and Design · **Group:** MTUCA2Group
**Members:** Philip Dawson-Gariepy, Danil Kramnov, Oleksandr Motoryhin, Zakary Snyder
**Repository:** https://github.com/MTUCA2Group/ca-analysis (tag `ca2-submission`)

The repository is the authoritative record. Every artefact named here links to its editable source; diagrams are exported beside their `.puml` files.

---

## 1. Introduction and Product Goal

Kerry Local Food Hub collects produce from local producers and allocates it to household, hospitality and community customers. Its core problem is that goods received are not the same as goods available: some fail checking, some are held, and allocations are made from stock that may not exist. CA2 designs the part of a system that fixes this.

**Product Goal:** give Kerry Local Food Hub staff and volunteers one reliable record of what has arrived, what is held and what is available, so that customers receive only checked goods, shortfalls follow customers' stated preferences, and every allocated item can be traced to its producer and batch ([DR-002](../decisions/DR-002-product-goal-and-dod.md)).

We designed three use cases in detail: UC-02 Receive delivery, UC-03 Release held stock and UC-05 Allocate stock. Each follows one chain: backlog item → use case and Gherkin → system sequence diagram → operation contract → CRC and GRASP → sequence diagram → integrated design class diagram.

---

## 2. Scenario Selection and Agreed Baseline

Each member presented their CA1 scenario, and the group compared all four on the brief's criteria: manageable scope, behavioural richness, object-oriented design potential and suitability for use-case and interaction design ([DR-001](../decisions/DR-001-scenario-selection.md)).

| Criterion | 07 Energy Advice | **19 Local Food Hub** | 27 Outdoor Equipment | 32 Property Maintenance |
|---|---|---|---|---|
| Manageable scope | High | **High** | Medium | Low |
| Behavioural richness | Medium | **High** | High | High |
| OO design potential | Medium | **High** | High | Medium |
| Use-case and interaction design | Medium | **High** | Medium | Medium |

We selected **Scenario 19**. Its core problem, "received does not mean available", gives clear state changes (accepted, held, released, written off, allocated) with testable rules (BR-01, NFR-04). Outdoor Equipment was rejected because its eligibility and restriction rules were unconfirmed; Property Maintenance because its scope was too large and its status meanings undefined; Energy Advice because it had too little state change. The lecturer approved the selection; no expansion items were given.

**Reconciliation.** CA1 was not adopted unchanged. The [reconciliation record](../decisions/reconciliation-record.md) lists seven changes made against tag `ca1-baseline`, each through a reviewed change:

| ID | Change | Why |
|----|--------|-----|
| RC-01 | `StockLot` gains `heldQuantity`; every received line yields a lot unless rejected | A held remainder had nowhere to live ([SPK-01](../decisions/SPK-01-partial-acceptance.md)) |
| RC-02 | Shortage priority sits behind `AllocationPolicy` | Priority rules unconfirmed (Q-05); left open when UC-06 was descoped |
| RC-03 | The manager may reject during receipt | Avoids holding goods only to reject them later |
| RC-04 | `QualityCheck` belongs to `StockLot` and records released and rejected quantities | A check can release part and reject part |
| RC-05 | Returned perishables can never return to stock | CA1 contradicted A-08 |
| RC-06 | Staff or manager release held stock; only the manager rejects | Volunteers record arrival; staff complete checks |
| RC-07 | Abandoning a receipt keeps recorded outcomes | Avoids hiding goods already accepted |

The spike SPK-01 was the most significant baseline decision: one `StockLot` holding accepted, held and written-off quantities was chosen over a separate held-goods object, because one lot keeps one producer and batch (BR-03).

---

## 3. Selected Design Scope

We selected three use cases because together they cover the core of the Product Goal: goods arrive and are checked (UC-02), held goods are released or written off (UC-03), and checked goods are allocated with traceability (UC-05).

| Use case | Owner | User value | Requirements / rules | Depends on | Why selected |
|----------|-------|------------|----------------------|------------|--------------|
| UC-02 Receive delivery (+ UC-11) | Philip | US-01, US-02 | FR-02 to FR-06 · BR-01, BR-03 · A-02, A-03, A-04 · NFR-04, NFR-05 | — | Root cause of the problem (E-02, E-04); four outcomes, a permission rule, unit conversion and traceability |
| UC-03 Release held stock | Danil | US-02 | FR-06 · BR-01, BR-03 · A-04, A-08 · NFR-04, NFR-05 | Lots with held quantity | Completes the held → available / written-off lifecycle; two permission rules |
| UC-05 Allocate stock (+ UC-09 Trace item) | Alex | US-05 | FR-07, FR-09, FR-12 · BR-01, BR-03 · NFR-04 | Available lots | Keeps the producer and batch link when stock is split (E-07); must never over-allocate |

**Not selected.** UC-06 Handle shortfall was selected at first but descoped on 26 Nov because its owner did not contribute ([DR-011](../decisions/DR-011-scope-three-use-cases.md)); UC-05 already reports the shortfall, so UC-06 can be added without changing it. UC-01 is simple data entry, UC-07 depends on unresolved reopen rules (Q-11), UC-08 overlaps UC-03's write-off, and UC-10 only reads data.

---

## 4. Behavioural Design

All operations return `Result<T>`: a refusal is `Failure(code)` and changes nothing ([interface catalogue](../design/interface-catalogue.md) §2–3).

### 4.1 UC-02 Receive delivery

The [use case](../analysis/use-cases/UC-02-receive-delivery.md) has eleven extensions, including partial acceptance, holding, a volunteer refused when rejecting (A-04), a manager rejecting, a missing batch (A-03) and an unannounced delivery. Nine [Gherkin scenarios](../features/receive_delivery.feature) (GH-01, GH-02, GH-06 to GH-12) cover success, refusal and the accepted-quantity boundary, and map to US-01's acceptance criteria.

The [SSD](../design/ssd/SSD-S1-receive-delivery.puml) shows four system events: `startReceipt`, `addLine`, `recordLineReceipt` and `completeReceipt`. `recordLineReceipt` carries the richest behaviour, so its contract ([OC-03](../design/contracts/OC-S1-receive-delivery.md)) has five controlled failures. The most important is `NOT_PERMITTED` when a volunteer records *Rejected*. Its postconditions create a stock lot whose held quantity is never available, enforcing BR-01 at the moment goods enter the system. Abandoning a receipt is deliberately not a system event: recorded lines keep their outcomes (RC-07).

### 4.2 UC-03 Release held stock

The [use case](../analysis/use-cases/UC-03-release-held-stock.md) lets a staff member release held goods and the manager reject them. Its extensions refuse a volunteer (RC-06), refuse a non-manager who rejects (A-04), refuse a lot with nothing held, and refuse quantities that exceed what is held. [GH-13 to GH-17](../features/release_held_stock.feature) cover full release, part release with rejection, both permission refusals and the released-quantity boundary.

The [SSD](../design/ssd/SSD-S2-release-held-stock.puml) has two events. `listHeldLots` only reads data, so it has no contract. `recordQualityCheck` changes state, so [OC-05](../design/contracts/OC-S2-release-held-stock.md) specifies it: a `QualityCheck` is created and linked to the lot and user; held quantity decreases by released plus rejected; accepted increases by released; written-off increases by rejected. The lot's trace details never change, so released goods keep their producer and batch.

### 4.3 UC-05 Allocate stock

The [use case](../analysis/use-cases/UC-05-allocate-stock.md) allocates checked stock to an order line. Volunteers are refused; a fully allocated line is refused; held stock is never counted (BR-01); lots without a use-by date are used last. [GH-18 to GH-22](../features/allocate_stock.feature) cover allocation from one and several lots, the shortfall case and the never-over-allocate boundary, and [GH-05](../features/trace_item.feature) covers tracing.

The [SSD](../design/ssd/SSD-S3-allocate-stock.puml) has three events; only `allocateOrderLine` changes state ([OC-06](../design/contracts/OC-S3-allocate-stock.md)). Lots are taken earliest use-by first; for each lot used an `Allocation` is created, linked to the line and the lot, and the lot's allocated quantity grows by exactly what it gives. A shortfall is a success, not a failure: the remaining quantity is returned as the line's shortfall. The invariant `allocatedQuantity ≤ acceptedQuantity` holds for every lot (NFR-04).

---

## 5. Responsibilities: CRC and GRASP

Four GRASP decision records cover the design: [DR-005](../decisions/DR-005-receive-delivery-controller.md), [DR-006](../decisions/DR-006-stock-lot-creator.md), [DR-007](../decisions/DR-007-release-held-stock-responsibilities.md) and [DR-010](../decisions/DR-010-allocation-responsibilities.md). Each records candidates, the decision, the principle, a rejected alternative and consequences.

### 5.1 UC-02 Receive delivery

The [CRC cards](../design/crc/CRC-S1-receive-delivery.md) place every rule with the class that holds its data. `ReceiveDeliveryHandler` is a use-case controller (DR-005): it receives the four system events and coordinates, but makes no decisions. A single `HubController` was rejected because it would grow with every use case. `DeliveryLine` holds received and accepted quantities, so it checks that accepted never exceeds received (Information Expert) and creates the `StockLot` (Creator, DR-006); letting the handler create the lot was rejected because the "no lot when rejected" rule would sit outside the domain. `Delivery`, as aggregate root, completes the trace details because only it knows the producer and date. `ReceiptOutcome.permittedFor(role)` holds the rejection rule, so a change to A-04 touches one method (Protected Variations).

### 5.2 UC-03 Release held stock

The [CRC cards](../design/crc/CRC-S2-release-held-stock.md) give the quality check to `StockLot`, not to the controller (DR-007). The lot owns all three quantities, so it moves released goods from held to accepted and rejected goods from held to written off (Information Expert), and it creates the `QualityCheck` because it records its checks and holds the data to validate them (Creator). Permissions sit in `Role.mayRelease()` and `mayReject()`, so if the hub's answer to Q-04 or Q-07 differs, only `Role` changes (Protected Variations). The rejected alternative, a controller checking roles with `if` statements and setting quantities through setters, would let any caller bypass NFR-04. Quality checks are saved with their lot, avoiding a second repository whose saves could disagree.

### 5.3 UC-05 Allocate stock

The [CRC cards](../design/crc/CRC-S3-allocate-stock.md) split allocation between two experts (DR-010). `OrderLine` knows the requested quantity and its existing allocations, so it knows what is outstanding and creates each `Allocation` (Creator; the domain model records allocations against the line). `StockLot` alone knows its available quantity, so `StockLot.allocate` refuses anything above it, and `expiresBefore` holds the use-by ordering rule. Two alternatives were rejected: the controller creating allocations, which would put rules in the controller, and a repository returning lots already sorted, which would put a hub rule into storage.

**Integrated design class diagram.** The [integrated diagram](../design/DCD-integrated.puml) merges the three use-case fragments. It shows four controllers (one per use case, plus `TraceItemHandler` for UC-09), three aggregates (`Delivery`, `StockLot`, `Order`) and the shared ports. Every operation in it is either an SSD system operation or a message in a sequence diagram.

---

## 6. Object Interactions and Consistency

Each sequence diagram's first message is the system event from its SSD, and every later message maps to an operation in the integrated diagram. The message-to-operation tables are in the [traceability matrix](../analysis/traceability-ca2.md).

### 6.1 UC-02 Receive delivery

[SD-S1a](../design/sequence/SD-S1-record-line-receipt.puml) realises OC-03. The handler delegates to `Delivery.recordLine`, which completes the trace and passes the receipt to the line; the line checks permission, converts units, validates quantities and creates the lot. Saves happen only after the last check, so every refusal leaves the system unchanged. [SD-S1b](../design/sequence/SD-S1-complete-receipt.puml) and [SD-S1c](../design/sequence/SD-S1-start-receipt.puml) realise OC-04 and OC-01/OC-02, including creation of an unannounced delivery and its lines.

### 6.2 UC-03 Release held stock

[SD-S2](../design/sequence/SD-S2-release-held-stock.puml) realises OC-05. The handler reads the user, role and time, loads the lot, and calls `StockLot.recordCheck`. The lot asks `Role` whether the actor may release or reject, validates quantities against what is held, creates the `QualityCheck` and moves its quantities. The handler saves the lot only on success and returns the new available, held and written-off quantities.

### 6.3 UC-05 Allocate stock

[SD-S3a](../design/sequence/SD-S3-allocate-order-line.puml) realises OC-06. The handler checks the role, loads the order and the available lots, and calls `Order.allocateLine`, which delegates to the line. The line sorts lots with `expiresBefore`, asks each for `availableQuantity()`, calls `allocate` for the smaller of outstanding and available, and creates one `Allocation` per lot used. [SD-S3b](../design/sequence/SD-S3-trace-order-line.puml) realises the UC-09 trace by reading each allocation's trace entry.

### 6.4 Consistency across the three use cases

`StockLot` is the one class all three use cases change: UC-02 creates it, UC-03 moves held quantity, UC-05 allocates from it. The fragments first disagreed on its attribute names and on the available-quantity formula; merging them into the integrated diagram exposed both, and we fixed them in one reviewed change (DEF-02): `availableQuantity() = acceptedQuantity − allocatedQuantity`. A final check confirmed that every message in all six sequence diagrams maps to an operation in the integrated diagram, and every operation there is used.

---

## 7. Design Structure and Shared Interfaces

The [package view](../design/package-view.puml) has three layers. Presentation is out of scope. Each use case is a package (`receiving`, `stockdecisions`, `allocation`) holding its controller and slice-only classes. All three depend on `shared`, which holds the shared domain classes, ports and result types, and never on each other, so a change in one use case cannot break another.

The [interface catalogue](../design/interface-catalogue.md) fixes the shared vocabulary:

- **Result convention:** every operation that can be refused returns `Result<T>`; a failure changes nothing, and controllers save only on success.
- **Error codes:** `NOT_FOUND`, `NOT_PERMITTED`, `INVALID_QUANTITY`, `INVALID_STATE`, `INVALID_TRACE`. A use case may not invent its own.
- **Roles:** `VOLUNTEER` ⊂ `STAFF` ⊂ `MANAGER`, read from `AuditContext`, never passed by the actor.
- **Ports:** one repository per aggregate root (`DeliveryRepository`, `StockLotRepository`, `OrderRepository`), plus `ProducerRepository`, `ProductRepository`, `AuditContext` and `Clock`. Ports are called by controllers, not domain classes.
- **StockLot rules:** which use case changes which quantity, and the availability invariant.

---

## 8. Design Evaluation

**Cohesion.** Each use case has its own controller (`ReceiveDeliveryHandler`, `ReleaseHeldStockHandler`, `AllocateStockHandler`, plus `TraceItemHandler`) rather than one hub facade (DR-005). Controllers only coordinate; rules sit with the objects that hold the data: `DeliveryLine` checks accepted against received, `StockLot` guards held versus available and records quality checks (DR-007), and `OrderLine` allocates from lots (DR-010). The cost is repetition: every controller reads the user, role and time before delegating.

**Coupling.** Controllers depend on repository interfaces, never on storage, and use-case packages depend only on `shared`. The strongest coupling is around `StockLot`: all three use cases change it, so a change to its quantities affects every slice. We accepted this because one lot per received line keeps one producer and batch (SPK-01); splitting it would have spread traceability across objects.

**Object validity.** Objects are created valid or not at all: `Delivery.startUnannounced` sets the unannounced invariants, `StockLot` is constructed with its quantities, and every operation returns `Result<T>`, so a refusal changes nothing. No class exposes a public status or quantity setter.

**Main risk found in evaluation.** The manager-only rejection rule (A-04) is phrased twice: `ReceiptOutcome.permittedFor(role)` at receipt and `Role.mayReject()` in the quality check. Both rely on `Role`, but if Q-04 changes, both must change. The first refactoring we would make is for `permittedFor` to delegate to `Role.mayReject()`.

**Assumptions.** A-02 fixed unit conversion per product; A-04 only the manager rejects; RC-05 perishables never return to stock; lots are allocated earliest use-by first.

**Rejected alternatives.** A single `HubController` (DR-005); a separate held-goods object (SPK-01 option B); the controller creating stock lots (DR-006); the controller checking roles and setting quantities (DR-007); a repository returning lots pre-sorted by use-by date (DR-010).

**Limitations.** UC-06 Handle shortfall was descoped (DR-011), so shortage priority (RC-02) and customer substitution preferences are not designed. The design does not cover concurrent recording of the same line, a database design, or UC-01, UC-07, UC-08 and UC-10. A partial release leaves one lot with mixed history, kept only in its quality-check records.

---

## 9. Process and Review Evidence

**Backlog and board.** The Product Backlog and iteration goals are on the Trello board (*add URL*), with lists Backlog, Ready, In Progress, Peer Review, Blocked and Done. Cards use stable IDs (US, DES, SPK, DEF), name an owner and reviewer, and link to the pull request that completed them. Captures of the board are in the appendix.

**Repository.** Work was done on one branch per backlog item and merged through pull requests. Decisions were recorded as dated records (DR-001 to DR-011, SPK-01), and two defects found by checking the models against each other (DEF-01 multiplicity, DEF-02 availability formula) were fixed in separate changes.

**Iterations.** Iteration 1 agreed the scenario, Product Goal, roles and reconciled baseline. Iteration 2 produced the three use-case chains, the interface catalogue and the integrated design. The updated brief on 25 Nov removed CA3, so the CA3 material was removed and recorded in DR-004.

**Review.** Early pull requests were merged by their authors before review. We recognised this, turned on branch protection requiring one approval, and recorded reviews on the earlier pull requests afterwards. The [retrospective](../docs/reflection/retrospective.md) records this as the main problem and branch protection as the improvement.

---

## 10. AI Use and How It Was Checked

Members used Claude (Anthropic) as declared in the [group AI declaration](../decisions/ai-declaration-group.md) and individual logs. It was used for templates, first drafts of design artefacts and dossier text, consistency checks between models and wording. It did not make scope or design decisions on its own: each significant AI-supported change is listed in [DR-009](../decisions/DR-009-ai-supported-design-changes.md) with how it was evaluated.

AI output was checked in three ways. First, against the brief and Session 14's design-ready audit, which found naming and sequence-diagram problems that were then fixed. Second, by independent evaluation: SPK-01 compared the one-lot design against an alternative before it was accepted. Third, through review of pull requests by a member who did not author the change. Changed or rejected suggestions are recorded in DR-009 and the individual logs.

---

## Appendices

- A. [CA2 traceability matrix and consistency evidence](../analysis/traceability-ca2.md)
- B. Decision records: `decisions/`
- C. Board captures: *(add images)*
- D. Individual contribution statements and AI declarations: submitted separately by each member