Feature: Attractor
  In order to calculate churn vs complexity
  As a CLI
  I want to use flog and churn

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor calc -v`
    Then the output should contain "Calculated churn and complexity"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor calc --format=csv --type=rb`
    Then the output should contain "file_path,score,complexity,churn,type,refactor"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor report --type=rb`
    # Then an HTML file should be generated
    Then the output should contain "Generated HTML report at"
    Then the output should contain "attractor_output/index.html"
    # Then the output should contain "attractor_output/index.js.html"
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

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor -v`
    Then the output should contain "Attractor version"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor --version`
    Then the output should contain "Attractor version"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor clean`
    Then the output should contain "Clearing attractor cache"

  Scenario:
    When I cd to "../../spec/fixtures/rails_app_with_gemfile"
    And I run `attractor init -v`
    Then the output should contain "Warming attractor cache"
    Then the output should contain "Calculating"
