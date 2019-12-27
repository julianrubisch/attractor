Feature: Attractor
  In order to calculate churn vs complexity
  As a CLI
  I want to use flog and churn

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor calc`
    Then the output should contain "Calculated churn and complexity"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor report --format html`
    # Then an HTML file should be generated
    Then the output should contain "Generated HTML report at"
    Then the output should contain "attractor_output/index.rb.html"
    Then the output should contain "attractor_output/index.js.html"
    Then the output should contain "Opening browser window..."

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor report --no-open-browser`
    Then the output should not contain "Opening browser window..."

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor report --watch`
    Then the output should contain "Listening for file changes..."

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor serve`
    Then the output should contain "Serving attractor at http://localhost:7890"
    Then the output should contain "Opening browser window..."
    Then the output should contain "Serving attractor at http://localhost:7890"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor serve -t js`

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor serve --ci`
    Then the output should not contain "Opening browser window..."
