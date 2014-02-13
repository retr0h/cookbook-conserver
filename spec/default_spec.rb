# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs server' do
    expect(chef_run).to include_recipe 'conserver::client'
  end
end
