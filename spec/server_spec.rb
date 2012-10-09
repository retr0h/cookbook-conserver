require "chefspec"

describe "conserver::server" do
  before { @chef_run = ChefSpec::ChefRunner.new.converge "conserver::server" }

  it "installs ipmitool" do
    chef_run = ChefSpec::ChefRunner.new

    Chef::Recipe.any_instance.stub(:include_recipe)
    Chef::Recipe.any_instance.should_receive(:include_recipe).with("ipmitool")

    chef_run.converge "conserver::server"
  end

  it "installs conserver::client" do
    chef_run = ChefSpec::ChefRunner.new

    Chef::Recipe.any_instance.stub(:include_recipe)
    Chef::Recipe.any_instance.should_receive(:include_recipe).with("conserver::client")

    chef_run.converge "conserver::server"
  end

  it "installs package" do
    @chef_run.should upgrade_package "conserver-server"
  end

  it "starts service" do
    @chef_run.should start_service "conserver-server"
  end

  it "enables service" do
    @chef_run.should set_service_to_start_on_boot "conserver-server"
  end

  describe "server.conf" do
    before { @file = "/etc/conserver/server.conf" }

    it "has proper owner" do
      @chef_run.template(@file).should be_owned_by("root", "root")
    end

    it "has proper modes" do
      m = @chef_run.template(@file).mode

      sprintf("%o", m).should == "644"
    end

    it "has daemon opts" do
      @chef_run.should create_file_with_content @file,
        %Q{OPTS='-p 3109 -M 127.0.0.1'}
    end

    it "restarts conserver-server" do
      pending
    end
  end

  describe "conserver.passwd" do
    before do
      @file = "/etc/conserver/conserver.passwd"
      @chef_run = ChefSpec::ChefRunner.new do |node|
        node['conserver'] = {}
        node['conserver']['access'] = {}
        node['conserver']['access']['pass'] = "password"
      end
      @chef_run.converge "conserver::server"
    end

    it "has proper owner" do
      @chef_run.template(@file).should be_owned_by("conservr", "root")
    end

    it "has proper modes" do
      m = @chef_run.template(@file).mode

      sprintf("%o", m).should == "600"
    end

    it "has user:password" do
      @chef_run.should create_file_with_content @file,
        %Q{root:password}
    end

    it "restarts conserver-server" do
      pending
    end
  end

  describe "conserver.passwd" do
    before do
      @file = "/etc/conserver/conserver.cf"
      Chef::Recipe.any_instance.should_receive(:search)
      @chef_run = ChefSpec::ChefRunner.new.converge "conserver::server"
    end

    it "has proper owner" do
      @chef_run.template(@file).should be_owned_by("root", "root")
    end

    it "has proper modes" do
      m = @chef_run.template(@file).mode

      sprintf("%o", m).should == "644"
    end

    it "has user:password" do
      @chef_run.should create_file_with_content @file,
        %Q{root:password}
    end

    it "has logfile" do
      @chef_run.should create_file_with_content @file,
        %Q{logfile /var/log/conserver/&.log}
    end

    it "has allowed" do
      @chef_run.should create_file_with_content @file,
        %Q{allowed 127.0.0.1}
    end

#<% @servers.each do |server| %>
#<% puts server %>
#console <%= server['hostname'] %> {
#  master localhost;
#  type exec;
#  exec <%= node['ipmitool']['cmd'] %> -f <%= ::File.join(node['conserver']['conf_dir'], ".ipmipass") %> -H <%= server['ipmi']['address'] %> -U root -C 3 -I lanplus sol activate;
#  idletimeout <%= node['conserver']['idletimeout'] %>;
#}
#<% end %>

    it "restarts conserver-server" do
      pending
    end
  end
end
