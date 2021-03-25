# frozen_string_literal: true

Then("an HTML file should be generated") do
  expect(File).to exist("attractor_output/index.html")
end
