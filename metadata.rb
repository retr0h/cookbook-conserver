name 'conserver'
maintainer 'John Dewey'
maintainer_email 'john@dewey.ws'
license 'Apache 2.0'
description 'Installs/Configures conserver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.4'

recipe 'conserver', 'Installs/Configures conserver'
recipe 'conserver::client', 'Installs/Configures conserver-client'
recipe 'conserver::server', 'Installs/Configures conserver-server'

provides 'conserver::client'
provides 'conserver::server'

supports 'debian'
supports 'ubuntu'

depends 'ipmitool'
