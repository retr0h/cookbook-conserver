[![Build Status](https://travis-ci.org/retr0h/cookbook-conserver.png?branch=master)](https://travis-ci.org/retr0h/cookbook-conserver)

Description
===========

Installs/Configures conserver

Assumes the node has IPMI connectivity to `node['ipmi']['address']` found by `node['conserver']['server_search']`.

Requirements
============

* Chef 0.8+
* ipmitool
* Ohai [ipmi.rb](https://bitbucket.org/retr0h/ohai/src) plugin

Attributes
==========

* `default['conserver']['server_search']` - The search to determine the servers to connect to. 
* `default['conserver']['conf_dir']` - The directory to conserver config files.
* `default['conserver']['access']['allowed']` - The list of hostnames are added to the 'allowed' list, which grants connections from the hosts but requires username authentication.
* `default['conserver']['access']['user']` - The console user to connect as.
* `default['conserver']['password']` - The console password to use when connecting.  Generate a password via `openssl passwd -1 "theplaintextpassword"`.
* `default['conserver']['logfile']` - Set the logfile to write to when in daemon mode.
* `default['conserver']['idletimeout']` - The idle timeout of the console.
* `default['conserver']['server']['port']` - Set the TCP port for the master process to listen on.
* `default['conserver']['server']['master']` - Bind to a particular IP address (like '127.0.0.1') instead of all interfaces.
* `default['conserver']['server']['user']` - The user conserver runs as.
* `default['conserver']['ipmi']['command']` - The IPMI SOL command to execute.
* `default['conserver']['ipmi']['user']` - The IPMI user to connect as.
* `default['conserver']['ipmi']['password']` - The IPMI password to use when connecting.

Usage
=====

```json
"run_list": [
    "recipe[conserver]"
]
```

default
----

Installs/Configures conserver-client

client
----

Installs/Configures conserver-client

To connect to the server as a client:

    $ console -M `node['conserver']['server']['master']` -p `node['conserver']['server']['port']` -l `node['conserver']['access']['user']` `node['hostname']`

e.g.:

    $ console -M 127.0.0.1 -p 3109 -l admin o11r1

To simplify add the following to the users .consolerc.  This should probably be added
to the cookbook at some point.

    config * {
      master `node['conserver']['server']['master']`;
      port `node['conserver']['server']['port']`;
      username `node['conserver']['access']['user']`;
    }

The command now becomes:

    $ console o11r1

server
----

Installs/Configures conserver-server

Testing
=====

This cookbook is using [ChefSpec](https://github.com/acrmp/chefspec) for
testing.  Should run the following before commiting.  It will run your tests,
and check for lint errors.

    % ./run_tests.bash

License and Author
==================

Author:: John Dewey (<john@dewey.ws>)

Copyright 2012-2013, John Dewey

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
