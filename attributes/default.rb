#
# Cookbook Name:: conserver
# Recipe:: default
#
# Copyright 2012 John Dewey
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

include_attribute "ipmitool"

default["conserver"]["server_search"] = "*:*"
default['conserver']['conf_dir'] = ::File.join ::File::SEPARATOR, "etc", "conserver"
default['conserver']['access']['allowed'] = "127.0.0.1"
default['conserver']['access']['user'] = "root"
# TODO: default['conserver']['access']['pass']
default['conserver']['logfile'] = ::File.join ::File::SEPARATOR, "var", "log", "conserver", "&.log"
default['conserver']['idletimeout'] = "4h"

default['conserver']['server']['port'] = "3109"
default['conserver']['server']['master'] = "127.0.0.1"
default['conserver']['server']['user'] = "conservr" # daemon runs as
