require "spec_helper"

describe "using the flavors api" do

  context "to show" do
    include_context "rummrc"
    When { VCR.use_cassette("flavors/show") {run "rumm show flavors"}}
    Then {all_stdout =~ /performance1-1    1 GB Performance/}
    And {last_exit_status.should eql 0}
  end

  context "to get help" do
    Given { rumm "help show flavors" }
    Then { all_stdout.match "Shows a list of all of the server flavors available on Rackspace" }
  end

end
