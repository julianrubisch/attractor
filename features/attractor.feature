Feature: Attractor
  In order to calculate churn vs complexity
  As a CLI
  I want to use flog and churn

  Scenario:
    When I run `attractor calc`
    Then the output should contain "Calculated churn and complexity"

  Scenario:
    When I run `attractor report --format html`
    Then an HTML file should be generated
    Then the output should contain "Generated HTML report at"
    Then  the output should contain "attractor_output/index.html"
