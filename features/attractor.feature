Feature: Attractor
  In order to calculate churn vs complexity
  As a CLI
  I want to use flog and churn

  Scenario:
    When I run `attractor calc`
    Then the output should contain "Calculated churn and complexity"
