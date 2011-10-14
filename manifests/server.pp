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
# Class: rsync::server
#
# This class provides a method to set up a fully functioning rsync server.
#
# The main idea behind this was to work around limitations of the native Puppet
# fileserving type.
#
# Most usual options are supported, but there are far too many to tackle all of
# them at once.
#
# This mainly daemonizes rsync and keeps it running.
# ---
#
class rsync::server inherits rsync {

  concat_build { "rsync":
    order => ["global", "*.section"],
    target => "/etc/rsyncd.conf",
    require => Package["rsync"]
  }

  file { "/etc/rsyncd.conf":
    owner => "root",
    group => "root",
    mode => "400",
    checksum => "md5",
    ensure => "present",
    audit => content,
    subscribe => Concat_build["rsync"],
    require => Package["rsync"],
    notify => Service["rsync"]
  }

  service { "rsync": 
    provider => "base",
    ensure => "running",
    binary => "/usr/bin/rsync",
    start => "sleep 1; /usr/bin/rsync --daemon --config=/etc/rsyncd.conf",
    stop => "/bin/kill `cat \\`grep \"pid file\" /etc/rsyncd.conf | cut -f4 -d' '\\``",
    require => [ File["/etc/rsyncd.conf"], Package["rsync"] ]
  }
}
