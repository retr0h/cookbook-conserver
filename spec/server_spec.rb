require "chefspec"

describe "conserver::server" do
  before do
    ::Chef::Recipe.any_instance.stub(:search)
    @chef_run = ::ChefSpec::ChefRunner.new.converge "conserver::server"
  end

  it "installs ipmitool" do
    chef_run = ::ChefSpec::ChefRunner.new

    ::Chef::Recipe.any_instance.stub(:include_recipe)
    ::Chef::Recipe.any_instance.should_receive(:include_recipe).with("ipmitool")

    chef_run.converge "conserver::server"
  end

  it "installs conserver::client" do
    chef_run = ::ChefSpec::ChefRunner.new

    ::Chef::Recipe.any_instance.stub(:include_recipe)
    ::Chef::Recipe.any_instance.should_receive(:include_recipe).with("conserver::client")

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
      resource = [ "conserver-server", "service", "delayed" ]

      @chef_run.template(@file).notifies(*resource).should be_true
    end
  end

  describe ".ipmipass" do
    before do
      @file = "/etc/conserver/.ipmipass"
      @chef_run = ::ChefSpec::ChefRunner.new do |node|
        node.set['conserver'] = {}
        node.set['conserver']['ipmi'] = {}
        node.set['conserver']['ipmi']['password'] = "password"
      end
      @chef_run.converge "conserver::server"
    end

    it "has proper owner" do
      @chef_run.file(@file).should be_owned_by("conservr", "root")
    end

    it "has proper modes" do
      m = @chef_run.file(@file).mode

      sprintf("%o", m).should == "600"
    end

    it "has password" do
      @chef_run.should create_file_with_content @file,
        %Q{password}
    end
  end

  describe "conserver.passwd" do
    before do
      @file = "/etc/conserver/conserver.passwd"
      @chef_run = ::ChefSpec::ChefRunner.new do |node|
        node.set['conserver'] = {}
        node.set['conserver']['access'] = {}
        node.set['conserver']['access']['user'] = "user"
        node.set['conserver']['access']['password'] = "password"
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
        %Q{user:password}
    end

    it "restarts conserver-server" do
      resource = [ "conserver-server", "service", "delayed" ]

      @chef_run.template(@file).notifies(*resource).should be_true
    end
  end

  describe "conserver.passwd" do
    before do
      @file = "/etc/conserver/conserver.cf"
      ::Chef::Recipe.any_instance.stub(:search).with(:node, "id:* AND chef_environment:_default").and_return([
        {
          "hostname" => "node1.example.com",
          "ipmi" => {
            "address" => "172.16.2.1"
          }
        },
        {
          "hostname" => "node2.example.com",
          "ipmi" => {
            "address" => "172.16.2.2"
          }
        }
      ])
      @chef_run = ::ChefSpec::ChefRunner.new.converge "conserver::server"
    end

    it "has proper owner" do
      @chef_run.template(@file).should be_owned_by("root", "root")
    end

    it "has proper modes" do
      m = @chef_run.template(@file).mode

      sprintf("%o", m).should == "644"
    end

    it "has logfile" do
      @chef_run.should create_file_with_content @file,
        %Q{logfile /var/log/conserver/&.log}
    end

    it "has allowed" do
      @chef_run.should create_file_with_content @file,
        %Q{allowed 127.0.0.1}
    end

    it "has console" do
      @chef_run.should create_file_with_content @file,
        %Q{console node1.example.com}
    end

    it "has idletimeout" do
      @chef_run.should create_file_with_content @file,
        %Q{idletimeout 4h}
    end

    it "has exec" do
      @chef_run.should create_file_with_content @file,
        %Q{exec /usr/bin/ipmitool -f /etc/conserver/.ipmipass -H 172.16.2.1 -U root -C 3 -I lanplus sol activate;}
    end

    it "logs unsupported when running in Chef Solo" do
      pending
    end

    it "restarts conserver-server" do
      resource = [ "conserver-server", "service", "delayed" ]

      @chef_run.template(@file).notifies(*resource).should be_true
    end
  end
end
