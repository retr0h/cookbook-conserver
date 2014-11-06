# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::client' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  it 'installs package' do
    expect(chef_run).to upgrade_package 'conserver-client'
  end
end
