# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::server' do
  before { allow_any_instance_of(Chef::Recipe).to receive(:search) }
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:node) { runner.node }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs ipmitool' do
    expect(chef_run).to include_recipe 'ipmitool'
  end

  it 'installs conserver::client' do
    expect(chef_run).to include_recipe 'conserver::client'
  end

  it 'installs package' do
    expect(chef_run).to upgrade_package 'conserver-server'
  end

  it 'starts service' do
    expect(chef_run).to start_service 'conserver-server'
  end

  it 'enables service' do
    expect(chef_run).to enable_service 'conserver-server'
  end

  context 'server.conf' do
    let(:file) { chef_run.template '/etc/conserver/server.conf' }

    it 'has proper owner' do
      expect(file.owner).to eq 'root'
      expect(file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(format('%o', file.mode)).to eq '644'
    end

    it 'has daemon opts' do
      expect(chef_run).to render_file(file.name)
        .with_content "OPTS='-p 3109 -M 127.0.0.1'"
    end

    it 'restarts conserver-server' do
      expect(file).to notify('service[conserver-server]').to(:restart)
    end
  end

  context '.ipmipass' do
    before { node.override['conserver']['ipmi']['password'] = 'password' }
    let(:file) { chef_run.file '/etc/conserver/.ipmipass' }

    it 'has proper owner' do
      expect(file.owner).to eq 'conservr'
      expect(file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(format('%o', file.mode)).to eq '600'
    end

    it 'has password' do
      expect(chef_run).to render_file(file.name)
        .with_content 'password'
    end
  end

  context 'conserver.passwd' do
    before do
      node.override['conserver']['access']['user'] = 'user'
      node.override['conserver']['access']['password'] = 'password'
    end
    let(:file) { chef_run.template '/etc/conserver/conserver.passwd' }

    it 'has proper owner' do
      expect(file.owner).to eq 'conservr'
      expect(file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(format('%o', file.mode)).to eq '600'
    end

    it 'has user:password' do
      expect(chef_run).to render_file(file.name)
        .with_content 'user:password'
    end

    it 'restarts conserver-server' do
      expect(file).to notify('service[conserver-server]').to(:restart)
    end
  end

  context 'conserver.passwd' do
    before do
      allow_any_instance_of(Chef::Recipe).to receive(:search)
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
    end
    let(:file) { chef_run.template '/etc/conserver/conserver.cf' }

    it 'has proper owner' do
      expect(file.owner).to eq 'root'
      expect(file.group).to eq 'root'
    end

    it 'has proper modes' do
      expect(format('%o', file.mode)).to eq '644'
    end

    it 'has logfile' do
      expect(chef_run).to render_file(file.name)
        .with_content 'logfile /var/log/conserver/&.log'
    end

    it 'has allowed' do
      expect(chef_run).to render_file(file.name)
        .with_content 'allowed 127.0.0.1'
    end

    it 'has console' do
      expect(chef_run).to render_file(file.name)
        .with_content 'console node1.example.com'
    end

    it 'has idletimeout' do
      expect(chef_run).to render_file(file.name)
        .with_content 'idletimeout 4h'
    end

    it 'has exec' do
      cmd  = 'exec /usr/bin/ipmitool '
      cmd += '-f /etc/conserver/.ipmipass '
      cmd += '-H 172.16.2.1 -U root -C 3 -I lanplus sol activate;'

      expect(chef_run).to render_file(file.name).with_content cmd
    end

    it 'restarts conserver-server' do
      expect(file).to notify('service[conserver-server]').to(:restart)
    end
  end
end
