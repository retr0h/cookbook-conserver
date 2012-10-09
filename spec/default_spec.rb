require "chefspec"

describe "conserver::default" do
  it "installs server" do
    chef_run = ChefSpec::ChefRunner.new

    Chef::Recipe.any_instance.should_receive(:include_recipe).with("conserver::server")

    chef_run.converge "conserver::default"
  end
end
