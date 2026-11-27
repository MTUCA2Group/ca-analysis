# Links: UC-06 Handle shortfall · US-03, US-04 · FR-08, FR-10, BR-05, NFR-04
# Slice: S4 Handle shortfall
Feature: Handle stock shortfalls
  Hub staff resolve shortfalls by following each customer's recorded
  preferences, so customers only receive what they have agreed to and
  hospitality customers hear about shortfalls before delivery.

  Background:
    Given staff member "Ciarán" is resolving shortfalls at 15:00
    And household customer "Niamh Doyle" has an order line for 2 kg of "Cherry tomatoes" with 0 kg allocated
    And "Cherry tomatoes" has 0 kg available

  Rule: Only substitutes the customer has permitted may be allocated (BR-05)

    @GH-23 @FR-08 @BR-05 @UC-06 @S4
    Scenario: Permitted substitute is available
      Given "Niamh Doyle" permits "Plum tomatoes" as a substitute for "Cherry tomatoes"
      And "Plum tomatoes" has 5 kg available
      When Ciarán resolves the line by substituting "Plum tomatoes"
      Then 2 kg of "Plum tomatoes" is allocated to the order line
      And the order line has no remaining shortfall
      And "Plum tomatoes" has 3 kg available
      And the resolution is recorded by "Ciarán" at 15:00

    @GH-24 @FR-08 @BR-05 @UC-06 @S4
    Scenario: Permitted substitute has no stock
      Given "Niamh Doyle" permits "Plum tomatoes" as a substitute for "Cherry tomatoes"
      And "Plum tomatoes" has 0 kg available
      When Ciarán resolves the line by substituting "Plum tomatoes"
      Then no stock is allocated
      And the order line still shows a shortfall of 2 kg

    @GH-26 @BR-05 @UC-06 @S4
    Scenario: A substitute that is not permitted is refused
      Given "Niamh Doyle" permits no substitutes for "Cherry tomatoes"
      And "Plum tomatoes" has 5 kg available
      When Ciarán resolves the line by substituting "Plum tomatoes"
      Then the request is refused because the resolution is not permitted
      And no stock is allocated
      And "Plum tomatoes" still has 5 kg available

  Rule: A substitute never takes more than is available (NFR-04)

    @GH-25 @NFR-04 @UC-06 @S4
    Scenario: Substitute only up to the available quantity
      Given "Niamh Doyle" has an order line for 5 kg of "Cherry tomatoes" with 0 kg allocated
      And "Niamh Doyle" permits "Plum tomatoes" as a substitute for "Cherry tomatoes"
      And "Plum tomatoes" has 3 kg available
      When Ciarán resolves the line by substituting "Plum tomatoes"
      Then 3 kg of "Plum tomatoes" is allocated to the order line
      And the order line still shows a shortfall of 2 kg
      And "Plum tomatoes" has 0 kg available

  Rule: Hospitality customers are flagged for contact when supply is reduced (FR-10)

    @GH-27 @FR-08 @FR-10 @UC-06 @S4
    Scenario: Hospitality customer accepts a reduced quantity
      Given hospitality customer "Tralee Bistro" has an order line for 10 kg of "Rooster potatoes" with 6 kg allocated
      And "Tralee Bistro" accepts a reduced quantity for that line
      When Ciarán resolves the line by accepting the reduced quantity
      Then the order line has no remaining shortfall
      And the order is flagged for contact before delivery

  Rule: Only staff or the manager resolve shortfalls (A-13)

    @GH-28 @A-13 @UC-06 @S4
    Scenario: A volunteer cannot resolve a shortfall
      Given volunteer "Aoife" is signed in
      When Aoife tries to resolve the line by contacting the customer
      Then the request is refused because the actor is not permitted
      And the order line still shows a shortfall of 2 kg