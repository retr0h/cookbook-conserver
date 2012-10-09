Description
===========

Installs/Configures conserver

Requirements
============

* Chef 0.8+
* ipmitool

Attributes
==========

* `default['conserver']['server_search']` - The search to determine the servers to connect to. 
* `default['conserver']['conf_dir']` - The directory to conserver config files.
* `default['conserver']['access']['allowed']` - The list of hostnames are added to the 'allowed' list, which grants connections from the hosts but requires username authentication.
* `default['conserver']['access']['user']` - The console user to connect as.
* `default['conserver']['logfile']` - Set the logfile to write to when in daemon mode.
* `default['conserver']['idletimeout']` - The idle timeout of the console.
* `default['conserver']['server']['port']` - Set the TCP port for the master process to listen on.
* `default['conserver']['server']['master']` - Bind to a particular IP address (like '127.0.0.1') instead of all interfaces.
* `default['conserver']['server']['user']` - The user conserver runs as.

* default['conserver']['pass'] - The console password to use.

Usage
=====

```json
"run_list": [
    "recipe[conserver]"
]
```

default
----

Installs/Configures conserver

client
----

Installs/Configures conserver-client

server
----

Installs/Configures conserver-server

Testing
=====

This cookbook is using [ChefSpec](https://github.com/acrmp/chefspec) for testing.

    $ cd $repo
    $ bundle
    $ librarian-chef install
    $ ln -s ../ cookbooks/$short_repo_name # doesn't contain "cookbook-"
    $ foodcritic cookbooks/$short_repo_name
    $ rspec cookbooks/$short_repo_name

License and Author
==================

Author:: John Dewey (<john@dewey.ws>)

Copyright 2012, John Dewey

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
