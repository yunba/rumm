require "spec_helper"
require "job_provider"

describe "getting a jenkins job config xml" do
  use_natural_assertions
  Given(:job) { JobProvider.new.job_template *arguments  }

  context "with default arguments" do
    Given(:arguments) { ["https://github.com/hayesmp/railsgirls-app.git", "bundle exec rake"] }
    Then { not job.nil? }
    Then { job.class == String }
  end

  context "with custom arguments" do
    Given(:arguments) { ["https://github.com/hayesmp/rumm.git", "custom command"] }
    Then { job.include?("https://github.com/hayesmp/rumm.git")==true }
    Then { job.include?("custom command")==true }
  end
end