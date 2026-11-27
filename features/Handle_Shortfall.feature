Feature: Handle stock shortfalls
  Hub staff resolve stock shortfalls based on customers' recorded preferences.

  Rule: A customer only receives permitted quantities and substitutions (BR-05).

  @FR-08 @BR-05 @UC-06 @GH-23
  Scenario: Permitted substitute is available
    Given "Cherry tomatoes" has 0 kg available
    And "Plum tomatoes" has 5 kg available
    And household customer "Niamh Doyle" has ordered 2 kg of "Cherry tomatoes"
    And "Niamh Doyle" permits "Plum tomatoes" as a substitute for "Cherry tomatoes"
    When the staff member resolves the shortfall
    Then 2 kg of "Plum tomatoes" is allocated to the order
    And the shortfall is resolved
    And the allocation is linked to the order
    And "Plum tomatoes" now has 3 kg available

  @FR-08 @BR-05 @UC-06 @GH-24
  Scenario: No permitted substitute is available
    Given "Cherry tomatoes" has 0 kg available
    And "Plum tomatoes" has 0 kg available
    And household customer "Niamh Doyle" permits only "Plum tomatoes" as a substitute for "Cherry tomatoes"
    When the staff member resolves the shortfall
    Then the shortfall remains unresolved
    And the order line still shows the remaining shortfall

  @NFR-04 @UC-06 @GH-25
  Scenario: Resolve shortfall up to available quantity
    Given "Plum tomatoes" has 3 kg available
    And the order has a shortfall of 5 kg
    And the customer permits "Plum tomatoes" as a substitute
    When the staff member resolves the shortfall
    Then at most 3 kg of "Plum tomatoes" is allocated
    And the order line shows a remaining shortfall of 2 kg
    And the lot has 0 kg available
