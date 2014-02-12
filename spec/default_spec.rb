# encoding: UTF-8

require_relative 'spec_helper'

describe 'conserver::default' do
  it 'installs server' do
    chef_run = ChefSpec::Runner.new
    chef_run.converge 'conserver::default'

    expect(chef_run).to include_recipe 'conserver::client'
  end
end
