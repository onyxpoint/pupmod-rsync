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
# Setup the global section of /etc/rsyncd.conf.
# Note that the $address defaults to 127.0.0.1.
# This can only be defined ONCE and must be overridden to be changed.
#
# See rsyncd.conf(5) for details of the variables.
#
# _Global Variables_
#
# * $pupbuildloc
#
# _Templates_
#
# * rsyncd.conf.global.erb
define rsync::server::global (
# _Variables_
    $motd_file = "",
    $pid_file = "/var/run/rsyncd.pid",
    $syslog_facility = "daemon",
    $port = "873",
    $address = "127.0.0.1"
  ) {
  concat_fragment { "rsync+global":
    content => template("rsync/rsyncd.conf.global.erb")
  }
}
