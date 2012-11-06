require "chefspec"

describe "conserver::client" do
  before { @chef_run = ::ChefSpec::ChefRunner.new.converge "conserver::client" }

  it "installs package" do
    @chef_run.should upgrade_package "conserver-client"
  end
end
