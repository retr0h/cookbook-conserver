require "chefspec"

describe "conserver::default" do
  it "installs server" do
    chef_run = ::ChefSpec::ChefRunner.new

    ::Chef::Recipe.any_instance.should_receive(:include_recipe).with("conserver::client")

    chef_run.converge "conserver::default"
  end
end
