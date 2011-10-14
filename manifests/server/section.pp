#
# Copyright (C) 2011 Onyx Point, Inc. <http://onyxpoint.com/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS
# IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.  See the License for the specific language
# governing permissions and limitations under the License.
#
# _Description_
#
# Set up a 'section' of /etc/rsyncd.conf pertaining to a particular rsync share.
#
# See rsyncd.conf(5) for descriptions of most variables.
#
# _Variables_
#
# * $pupbuildloc
#
# _Templates_
#
# * rsyncd.conf.section.erb
define rsync::server::section (
# _Variables_
#
# $name
#     Becomes the name of the temporary file that will be part of a multi-part
#     build file.
#     Note: Do not add a '/' to the contents of the name variable.
#
# $auth_users
#     Set this to an array of allowed usernames for this section.
#
    $auth_users = "",
# $user_pass
#     An array of 'username:password' combinations to be added to the secrets file.
#     It is recommended that you use the included passgen function to generate the passwords.
#     If $user_pass is left blank but $auth_users is set, then random passwords
#     will be generated for you.
#
    $user_pass = "",
    $comment = "",
    $path,
    $use_chroot = "false",
    $max_connections = "0",
    $max_verbosity = "1",
    $lock_file = "/var/run/rsyncd.lock",
    $read_only = "true",
    $write_only = "false",
    $list = "false",
    $uid = "root",
    $gid = "root",
    $outgoing_chmod = "o-w",
    $ignore_nonreadable = "true",
    $transfer_logging = "true",
    $log_format = '"%o %h [%a] %m (%u) %f %l"',
    $dont_compress = "*.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz *.rar *.jar *.pdf *.sar *.war",
    $hosts_allow = "127.0.0.1",
    $hosts_deny = "*"
  ) {

  concat_fragment { "rsync+$name.section":
    content => template("rsync/rsyncd.conf.section.erb")
  }

  if $auth_users != "" {
    # Complete hackery to be able to use the passgen function in the following template.
    if false {
      passgen("false")
    }

    file { "/etc/rsync/${name}.rsyncd.secrets":
      ensure => 'file',
      owner => "$uid",
      group => "$gid",
      mode => '600',
      content => template("rsync/secrets.erb")
    }
  }
}
