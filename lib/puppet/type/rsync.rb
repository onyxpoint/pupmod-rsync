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
Puppet::Type.newtype(:rsync) do
  @doc = "Run an rsync command"

  newparam(:name) do
    isnamevar
  end

  newproperty(:do) do
    desc "Whether to push or pull from rsync server. Defaults to pull"
    newvalues(:push, :pull)
    defaultto :pull

    def retrieve
      resource[:do]
    end

    def insync?(is)
      output, status = provider.execute
      retval = true
      if status != 0 then
        if @resource[:logoutput] != false and @resource[:logoutput] != :false then
          output.each_line do |line|
            self.send(@resource[:loglevel], line.chomp)
          end
        end
        self.fail "Rsync exited with code #{status.to_s}"
      else
        if output !~ /^\s*$/ then
          if @resource[:logoutput] != false and @resource[:logoutput] != :false and @resource[:logoutput] != :on_failure then
            output.each_line do |line|
              self.send(@resource[:loglevel], line.chomp)
            end
          end
          retval = false
        end
      end
      retval
    end

    def sync
      debug "syncing..."
    end

    def change_to_s(currentvalue, newvalue)
      "executed successfully"
    end
  end

  newparam(:source) do
    desc "The fully qualified source path on the rsync server"
  end

  newparam(:source_path) do
    desc "The fully qualified source path on the rsync server"
  end

  newparam(:target) do
    desc "The fully qualified target path on the rsync client"
  end

  newparam(:target_path) do
    desc "The fully qualified target path on the rsync client"
  end

  newparam(:server) do
    desc "The hostname or IP of the rsync server"

    validate do |value|
      if value !~ /[a-zA-Z][a-zA-Z\-]*(\.[a-zA-Z][a-zA-Z\-]*)*/ then
        begin
          require 'ipaddr'
          IPAddr.new(value)
        rescue Exception
          fail Puppet::Error, "#{value} does not appear to be a valid hostname or IP address"
        end
      end
    end
  end

  newparam(:rsync_server) do
    desc "The hostname or IP of the rsync server"

    validate do |value|
      if value !~ /[a-zA-Z][a-zA-Z\-]*(\.[a-zA-Z][a-zA-Z\-]*)*/ then
        begin
          require 'ipaddr'
          IPAddr.new(value)
        rescue Exception
          fail Puppet::Error, "#{value} does not appear to be a valid hostname or IP address"
        end
      end
    end
  end

  newparam(:protocol) do
    desc "The protocol to use in connecting to the rsync server. Defaults to 'rsync'"
  end

  newparam(:proto) do
    desc "The protocol to use in connecting to the rsync server. Defaults to 'rsync'"
  end

  newparam(:path) do
    desc "The fully qualified path to the rsync executable"
  end

  newparam(:rsync_path) do
    desc "The fully qualified path to the rsync executable"
  end

  newparam(:preserve_acl, :boolean => true) do
    desc "Whether or not to preserve ACL. Defaults to true."
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:preserve_xattrs, :boolean => true) do
    desc "Whether or not to preserve extended attributes. Defaults to true."
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:preserve_owner, :boolean => true) do
    desc "Whether or not to preserve owner. Defaults to true."
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:preserve_group, :boolean => true) do
    desc "Whether or not to preserve group. Defaults to true."
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:preserve_devices, :boolean => true) do
    desc "Whether or not to preserve device files. Defaults to false."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:exclude) do
    desc "Exclude files matching PATTERN.  Multiple values may be specified as an array.  Defaults to ['.svn/','.git/']"

    munge do |value|
      [value].flatten
    end
    defaultto [".svn/",".git/"]
  end

  newparam(:timeout) do
    desc "I/O timeout in seconds. Defaults to 2"

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^\d+$/
          fail Puppet::Error, "Timeout must be an integer"
        end
        Integer(value)
      else
        value
      end
    end
  end

  newparam(:rsync_timeout) do
    desc "I/O timeout in seconds. Defaults to 2"

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^\d+$/
          fail Puppet::Error, "Timeout must be an integer"
        end
        Integer(value)
      else
        value
      end
    end
  end

  newparam(:logoutput) do
    desc "Whether to log output.  Defaults to logging output at the
      loglevel for the `exec` resource. Use *on_failure* to only
      log the output when the command reports an error.  Values are
      **true**, *false*, *on_failure*, and any legal log level."

    newvalues(:true, :false, :on_failure)
    defaultto :on_failure
  end

  newparam(:delete, :boolean => true) do
    desc "Whether to delete files that don't exist on server.  Defaults to false"
    newvalues(:true, :false)
    defaultto :false
  end 

  newparam(:bwlimit) do
    desc "KB/s to limit I/O bandwidth to"

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^\d+$/
          fail Puppet::Error, "bwlimit must be an integer"
        end
        Integer(value)
      else
        value
      end
    end
  end

  newparam(:copy_links, :boolean => true) do
    desc "Whether to copy links as symlinks.  Defaults to false"
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:size_only, :boolean => true) do
    desc "Whether to skip files that match in size.  Defaults to true"
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:no_implied_dirs, :boolean => true) do
    desc "Don't send implied dirs.  Defaults to true"
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:user) do
    desc "The username to use"
  end

  newparam(:password) do
    desc "The password to use. Only used if a username is specified
          If you want the password to be auto-generated, you can use the 
          'passgen' function in an inline_template.
            rsync { \"foo\":
              source => 'bar',
              target => '/tmp/foo',
              server => 'puppet',
              user => 'foo',
              password => inline_template(\"<%= Puppet::Parser::Functions::function('passgen'); '' %><%= scope.function_passgen(['$user']) %>\n\")
            }
         "
  end

  newparam(:pass) do
    desc "The password to use. Only used if a username is specified
          If you want the password to be auto-generated, you can use the 
          'passgen' function in an inline_template.
            rsync { \"foo\":
              source => 'bar',
              target => '/tmp/foo',
              server => 'puppet',
              user => 'foo',
              password => inline_template(\"<%= Puppet::Parser::Functions::function('passgen'); '' %><%= scope.function_passgen(['$user']) %>\n\")
            }
         "
  end

  autorequire(:user) do
    # Autorequire users if they are specified by name
    if user = self[:user] and user !~ /^\d+$/
      debug "Autorequiring User[#{user}]"
      user
    end
  end

  autorequire(:file) do
    path = []
    if not self[:server] then
      path << self[:target]
      path << self[:source]
    elsif self[:do] == :pull or self[:do].eql?('pull') then
      path << self[:target]
    else
      path << self[:source]
    end

    path.each do |val|
      debug "Autorequiring File[#{val}]"
    end

    path
  end

  validate do
    required_fields = [[:source, :source_path], [:target, :target_path]]
    aliases = [[:source, :source_path], [:target, :target_path], [:server, :rsync_server], [:protocol, :proto], [:path, :rsync_path], [:timeout, :rsync_timeout]]

    unless @parameters.include?(:path) or @parameters.include?(:rsync_path)
      self[:path] = "/usr/bin/rsync"
    end

    unless @parameters.include?(:protocol) or @parameters.include?(:proto)
      self[:protocol] = "rsync"
    end

    unless @parameters.include?(:timeout) or @parameters.include?(:rsync_timeout)
      self[:timeout] = 2
    end

    required_fields.each do |req|
      unless @parameters.include?(req.first) or @parameters.include?(req.last)
        fail Puppet::Error, "You must specify one of #{req.first} or #{req.last}."
      end
    end

    aliases.each do |a|
      if @parameters.include?(a.first) and @parameters.include?(a.last) then
        fail Puppet::Error, "You can only specify one of #{a.first} and #{a.last}"
      end
    end

    if (self[:server] or self[:rsync_server]) and self[:do] == :pull then
      full_paths = [:path, :rsync_path, :target, :target_path]
    elsif self[:server] or self[:rsync_server] then
      full_paths = [:path, :rsync_path, :source, :source_path]
    else
      full_paths = [:path, :rsync_path, :source, :source_path, :target, :target_path]
    end

    full_paths.each do |path|
      if self[path] then
        unless self[path] =~ /^\/$/ or self[path] =~ /^\/[^\/]/
          fail Puppet::Error, "File paths must be fully qualified, not '#{self[path]}'"
        end
      end
    end

    unless @parameters.include?(:server) or @parameters.include?(:rsync_server)
      if @parameters.include?(:protocol) or @parameters.include?(:proto) then
        debug "Protocol set without server, ignoring."
        @parameters.delete(:protocol)
        @parameters.delete(:proto)
      end
      if @parameters.include?(:user) then
        debug "User set without server, ignoring."
        @parameters.delete(:user)
      end
      if @parameters.include?(:password) or @parameters.include?(:pass) then
        debug "Password set without server, ignoring."
        @parameters.delete(:password)
        @parameters.delete(:pass)
      end
    end
 
    unless @parameters.include?(:user)
      if @parameters.include?(:password) or @parameters.include?(:pass) then
        debug "Password set without user, ignoring."
        @parameters.delete(:password)
        @parameters.delete(:pass)
      end
    end
    if @parameters.include?(:user) and not (@parameters.include?(:password) or @parameters.include?(:pass)) then
      fail Puppet::Error, "You must specify a password if you specify a user."
    end
  end
end
