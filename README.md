Puppet Rsync Module
====================

This module provides a native type to set up a rsync server and client.

It requires the [Concat Module](https://github.com/onyxpoint/pupmod-concat) released by Onyx Point.

Installation
------------

A spec file has been included that can be used to create an RPM if
required. Otherwise, just placing the directory in your modulepath
will work.

This module is known to be compatible with Puppet 2.6.

Basic Usage
-----------

To set up an rsync server, use something like the following:

include 'rsync::server'

# Set up the global configuration options.
rsync::server::global { 'global':
  address => '0.0.0.0'
}

# Now set up some rsync shares
rsync::server::section { 'default':
  comment => 'The default file path',
  path => '/path/to/share',
  hosts_allow => '1.2.3.4'
}
rsync::server::section { 'test':
  auth_users => 'testuser',
  comment => 'Test comment',
  path => '/some/path/to/test',
  hosts_allow => '3.4.5.6',
  outgoing_chmod => 'o-w'
}

To have a client pull from the rsync server, do the following:

include 'rsync'

rsync { 'foo':
  source => 'default/foo,
  target => '/tmp/foo',
  server => $rsync_server
}

Type Documentation
------------------
### rsync

Run an rsync command

#### Parameters

##### bwlimit

KB/s to limit I/O bandwidth to

##### copy_links

Whether to copy links as symlinks.  Defaults to false  Valid values are `true`, `false`.

##### delete

Whether to delete files that don't exist on server.  Defaults to false  Valid values are `true`, `false`.

##### do

Whether to push or pull from rsync server. Defaults to pull  Valid values are `push`, `pull`.

##### exclude

Exclude files matching PATTERN.  Multiple values may be specified as an array.  Defaults to ['.svn/','.git/']

##### logoutput

Whether to log output.  Defaults to logging output at the
loglevel for the `exec` resource. Use *on_failure* to only
log the output when the command reports an error.  Values are
**true**, *false*, *on_failure*, and any legal log level.  Valid values are `true`, `false`, `on_failure`.

##### name

##### no_implied_dirs

Don't send implied dirs.  Defaults to true  Valid values are `true`, `false`.

##### pass

The password to use. Only used if a username is specified
If you want the password to be auto-generated, you can use the 
'passgen' function in an inline_template.
  rsync { "foo":
    source => 'bar',
    target => '/tmp/foo',
    server => 'puppet',
    user => 'foo',
    password => inline_template("<%= Puppet::Parser::Functions::function('passgen'); '' %><%= scope.function_passgen(['$user']) %>
")
  }


##### password

The password to use. Only used if a username is specified
If you want the password to be auto-generated, you can use the 
'passgen' function in an inline_template.
  rsync { "foo":
    source => 'bar',
    target => '/tmp/foo',
    server => 'puppet',
    user => 'foo',
    password => inline_template("<%= Puppet::Parser::Functions::function('passgen'); '' %><%= scope.function_passgen(['$user']) %>
")
  }


##### path

The fully qualified path to the rsync executable

##### preserve_acl

Whether or not to preserve ACL. Defaults to true.  Valid values are `true`, `false`.

##### preserve_devices

Whether or not to preserve device files. Defaults to false.  Valid values are `true`, `false`.

##### preserve_group

Whether or not to preserve group. Defaults to true.  Valid values are `true`, `false`.

##### preserve_owner

Whether or not to preserve owner. Defaults to true.  Valid values are `true`, `false`.

##### preserve_xattrs

Whether or not to preserve extended attributes. Defaults to true.  Valid values are `true`, `false`.

##### proto

The protocol to use in connecting to the rsync server. Defaults to 'rsync'

##### protocol

The protocol to use in connecting to the rsync server. Defaults to 'rsync'

##### provider

The specific backend for provider to use. You will
seldom need to specify this -- Puppet will usually discover the
appropriate provider for your platform.  Available providers are:

* **rsync**: Rsync provider  Required binaries: `rsync`.    

##### rsync_path

The fully qualified path to the rsync executable

##### rsync_server

The hostname or IP of the rsync server

##### rsync_timeout

I/O timeout in seconds. Defaults to 2

##### server

The hostname or IP of the rsync server

##### size_only

Whether to skip files that match in size.  Defaults to true  Valid values are `true`, `false`.

##### source

The fully qualified source path on the rsync server

##### source_path

The fully qualified source path on the rsync server

##### target

The fully qualified target path on the rsync client

##### target_path

The fully qualified target path on the rsync client

##### timeout

I/O timeout in seconds. Defaults to 2

##### user

The username to use

Notes
-----

This does not handle tcpwrappers or iptables, you'll have to do that yourself.

TODO
----

Copyright
---------

Copyright (C) 2011 Onyx Point, Inc. <http://onyxpoint.com/>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
