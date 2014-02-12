# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::server' do
  before do
    Chef::Recipe.any_instance.stub(:search)
    @chef_run = ChefSpec::Runner.new.converge 'conserver::server'
  end

  it 'installs ipmitool' do
    chef_run = ChefSpec::Runner.new
    chef_run.converge 'conserver::server'

    expect(chef_run).to include_recipe 'ipmitool'
  end

  it 'installs conserver::client' do
    chef_run = ChefSpec::Runner.new
    chef_run.converge 'conserver::server'

    expect(chef_run).to include_recipe 'conserver::client'
  end

  it 'installs package' do
    expect(@chef_run).to upgrade_package 'conserver-server'
  end

  it 'starts service' do
    expect(@chef_run).to start_service 'conserver-server'
  end

  it 'enables service' do
    expect(@chef_run).to enable_service 'conserver-server'
  end

  describe 'server.conf' do
    before { @file = @chef_run.template '/etc/conserver/server.conf' }

    it 'has proper owner' do
      expect(@file.owner).to eq 'root'
      expect(@file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(sprintf('%o', @file.mode)).to eq '644'
    end

    it 'has daemon opts' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{OPTS='-p 3109 -M 127.0.0.1'}
    end

    it 'restarts conserver-server' do
      expect(@file).to notify('service[conserver-server]').to(:restart)
    end
  end

  describe '.ipmipass' do
    before do
      @chef_run = ChefSpec::Runner.new do |node|
        node.set['conserver'] = {}
        node.set['conserver']['ipmi'] = {}
        node.set['conserver']['ipmi']['password'] = 'password'
      end
      @chef_run.converge 'conserver::server'
      @file = @chef_run.file '/etc/conserver/.ipmipass'
    end

    it 'has proper owner' do
      expect(@file.owner).to eq 'conservr'
      expect(@file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(sprintf('%o', @file.mode)).to eq '600'
    end

    it 'has password' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{password}
    end
  end

  describe 'conserver.passwd' do
    before do
      @chef_run = ChefSpec::Runner.new do |node|
        node.set['conserver'] = {}
        node.set['conserver']['access'] = {}
        node.set['conserver']['access']['user'] = 'user'
        node.set['conserver']['access']['password'] = 'password'
      end
      @chef_run.converge 'conserver::server'
      @file = @chef_run.template '/etc/conserver/conserver.passwd'
    end

    it 'has proper owner' do
      expect(@file.owner).to eq 'conservr'
      expect(@file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(sprintf('%o', @file.mode)).to eq '600'
    end

    it 'has user:password' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{user:password}
    end

    it 'restarts conserver-server' do
      expect(@file).to notify('service[conserver-server]').to(:restart)
    end
  end

  describe 'conserver.passwd' do
    before do
      Chef::Recipe.any_instance.stub(:search)
        .with(:node, 'id:* AND chef_environment:_default AND ipmi:address')
        .and_return([
          {
            'hostname' => 'node1.example.com',
            'ipmi' => {
              'address' => '172.16.2.1'
            }
          },
          {
            'hostname' => 'node2.example.com',
            'ipmi' => {
              'address' => '172.16.2.2'
            }
          }
        ])
      @chef_run = ChefSpec::Runner.new.converge 'conserver::server'
      @file = @chef_run.template '/etc/conserver/conserver.cf'
    end

    it 'has proper owner' do
      expect(@file.owner).to eq 'root'
      expect(@file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(sprintf('%o', @file.mode)).to eq '644'
    end

    it 'has logfile' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{logfile /var/log/conserver/&.log}
    end

    it 'has allowed' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{allowed 127.0.0.1}
    end

    it 'has console' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{console node1.example.com}
    end

    it 'has idletimeout' do
      expect(@chef_run).to render_file(@file.name)
        .with_content %Q{idletimeout 4h}
    end

    it 'has exec' do
      cmd  = 'exec /usr/bin/ipmitool '
      cmd += '-f /etc/conserver/.ipmipass '
      cmd += '-H 172.16.2.1 -U root -C 3 -I lanplus sol activate;'

      expect(@chef_run).to render_file(@file.name).with_content cmd
    end

    it 'restarts conserver-server' do
      expect(@file).to notify('service[conserver-server]').to(:restart)
    end
  end
end
