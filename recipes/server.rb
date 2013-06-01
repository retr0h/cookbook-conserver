#
# Cookbook Name:: conserver
# Recipe:: server
#
# Copyright 2012-2013, John Dewey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "ipmitool"
include_recipe "conserver::client"

#TODO:FC003
servers = search :node, node["conserver"]["server_search"]

package "conserver-server" do
  action :upgrade
end

service "conserver-server" do
  supports :restart => true
  pattern  "conserver"

  action [ :enable, :start ]
end

file ::File.join(node['conserver']['conf_dir'], ".ipmipass") do
  owner   node['conserver']['server']['user']
  group   "root"
  mode    00600
  content node['conserver']['ipmi']['password']

  action :create
end

template ::File.join(node['conserver']['conf_dir'], "server.conf") do
  source "server.conf.erb"
  owner  "root"
  group  "root"
  mode   00644

  action :create

  notifies :restart, "service[conserver-server]"
end

template ::File.join(node['conserver']['conf_dir'], "conserver.passwd") do
  source "conserver.passwd.erb"
  owner  node['conserver']['server']['user']
  group  "root"
  mode   00600

  action :create

  notifies :restart, "service[conserver-server]"
end

template ::File.join(node['conserver']['conf_dir'], "conserver.cf") do
  source "conserver.cf.erb"
  owner  "root"
  group  "root"
  mode   00644

  action :create

  variables(
    :servers => servers
  )

  notifies :restart, "service[conserver-server]"
end
