# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::client' do
  before { @chef_run = ChefSpec::Runner.new.converge 'conserver::client' }

  it 'installs package' do
    expect(@chef_run).to upgrade_package 'conserver-client'
  end
end
