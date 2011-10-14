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
Summary: Rsync Puppet Module
Name: pupmod-rsync
Version: 1.0
Release: 6
License: Apache 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-concat >= 1.0-1
Requires: puppet-server >= 2.6
Buildarch: noarch

Prefix:"/etc/puppet/modules"

%description
This Puppet module provides the capability to configure rsync.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

# Make your directories here.
mkdir -p %{buildroot}/%{prefix}/rsync
mkdir -p %{buildroot}/%{prefix}/rsync/files
mkdir -p %{buildroot}/%{prefix}/rsync/manifests
mkdir -p %{buildroot}/%{prefix}/rsync/templates
mkdir -p %{buildroot}/%{prefix}/rsync/plugins

# Now install the files.
test -d manifests && cp -r manifests %{buildroot}/%{prefix}/rsync
test -d templates && cp -r templates %{buildroot}/%{prefix}/rsync
test -d lib && cp -r lib %{buildroot}/%{prefix}/rsync

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(0640,root,puppet)
%{prefix}/rsync

%changelog
* Sat Oct 1 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-6
- Added the genpass function and rspec tests.

* Thu Feb 3 2011 Morgan Haskel <morgan.haskel@onyxpoint.com> - 1.0-5
- Fixed typos in rsyslog command and test command templates
- Added rsync custom type
- Updated to use concat_build and concat_fragment custom types
- Updated retrieve to use rsync custom type

* Thu Jan 20 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-4
- Removed the ability to set $pull in rsync::push

* Mon Jan 10 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 1-3
- Added the ability to push to the rsync server. Simply set $pull to 'false' on
  rsync::retrieve.

* Tue Oct 26 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 1-2
- Converting all spec files to check for directories prior to copy.

* Wed Jul 14 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-0
- Update to support password protected rsync spaces.
  Passwords are auto-generated if required.

* Mon May 24 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-0
- Doc update and code refactor.

* Thu May 13 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.1-14
- Updated the 'exclude' param to match the man page. It works both with and
  without the '=' but not using '=' may be deprecated in the future.

* Wed Mar 17 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.1-13
- Now supports --no-implied-dirs by default. This prevents errors when doing
  things like copying symlinks over directories, etc... It is a $no_implied_dirs
  variable and can be turned off by assigning it to 'false'.

* Mon Nov 02 2009 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.1-12
- Made this more flexible and hopefully faster by default.
- The define now supports the copy_links and size_only options.
