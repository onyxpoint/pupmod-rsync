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
Puppet::Type.type(:rsync).provide :rsync do
  require 'fileutils'
  require 'puppet/util'

  desc "Rsync provider"

  commands :rsync_command => "rsync"

  def get_source
    source = ""
    if @resource[:source] then
      resource_source = @resource[:source]
    else
      resource_source = @resource[:source_path]
    end
    if @resource[:protocol] then
      resource_protocol = @resource[:protocol]
    else
      resource_protocol = @resource[:proto]
    end
    if @resource[:server] then
      resource_server = @resource[:server]
    else
      resource_server = @resource[:rsync_server]
    end

    if (@resource[:server] or @resource[:rsync_server]) and (@resource[:do] == :pull or @resource[:do].eql?("pull")) then
      source << resource_protocol
      source << "://"
      if @resource[:user] then
        source << "#{@resource[:user]}@"
      end
      source << resource_server
      source << "/" unless resource_source =~ /^\//
      source << resource_source
    else
      source << resource_source
    end
    source
  end

  def get_target
    target = ""
    if @resource[:target] then
      resource_target = @resource[:target]
    else
      resource_target = @resource[:target_path]
    end
    if @resource[:protocol] then
      resource_protocol = @resource[:protocol]
    else
      resource_protocol = @resource[:proto]
    end
    if @resource[:server] then
      resource_server = @resource[:server]
    else
      resource_server = @resource[:rsync_server]
    end

    if (@resource[:server] or @resource[:rsync_server]) and (@resource[:do] == :push or @resource[:do].eql?("push")) then
      target << resource_protocol
      target << "://"
      if @resource[:user] then
        target << "#{@resource[:user]}@"
      end
      target << resource_server
      target << "/" unless resource_target =~ /^\//
      target << resource_target
    else
      target << resource_target
    end
  end

  def get_flags
    flags = []
    flags << "-A" if @resource.preserve_acl?
    flags << "-X" if @resource.preserve_xattrs?
    flags << "-o" if @resource.preserve_owner?
    flags << "-g" if @resource.preserve_group?
    flags << "--delete" if @resource.delete?
    flags << "-D" if @resource.preserve_devices?
    flags << "--no-implied-dirs" if @resource.no_implied_dirs?
    if @resource.copy_links? then
      flags << "-L"
    else
      flags << "-l"
    end
    if @resource.size_only? then
      flags << "--size-only"
    else
      flags << "-c"
    end
  end

  def get_timeout
    timeout = "--timeout="
    timeout << "#{@resource[:timeout].to_s}"
    timeout
  end

  def get_exclude
    exclude = []
    if @resource[:exclude] then
      @resource[:exclude].each do |val|
        exclude << "--exclude='#{val}'"
      end
    end
    exclude
  end

  def get_bwlimit
    bwlimit = ''
    if @resource[:bwlimit] then
      bwlimit << "--bwlimit=#{@resource[:bwlimit].to_s}"
    end
    bwlimit
  end

  def get_password_file
    password_file = ''
    if @resource[:user] then
      password_file << "--password-file=/etc/rsync/#{@resource[:user]}"

      if @resource[:password] then
        password = @resource[:password]
      else
        password = @resource[:pass]
      end
      begin
        file = File.open("/etc/rsync/#{@resource[:user]}", "w")
        file.puts "#{password}\n"
        file.close
        FileUtils.chown("root", "root", "/etc/rsync/#{@resource[:user]}")
        FileUtils.chmod(0600, "/etc/rsync/#{@resource[:user]}")
      rescue Exception
        error "Error writing password to file /etc/rsync/#{@resource[:user]}"
      end
    end
    password_file
  end

  def build_command
    cmd = []
    if @resource[:path] then
      cmd << @resource[:path]
    else
      cmd << @resource[:rsync_path]
    end
    cmd << ['-i', '-p', '-H', '-S', '-z', '-r']
    cmd << get_flags
    cmd << get_exclude
    cmd << get_bwlimit
    cmd << get_timeout
    cmd << get_password_file
    cmd << get_source
    cmd << get_target
    cmd.flatten!
    cmd = cmd.reject{ |x| x =~ /^\s*$/ }
    cmd
  end

  def execute
    cmd = build_command.join(" ")
    debug "Executing command #{cmd}"
    output = %x{#{cmd} 2>&1}
    status = $?.exitstatus

    return output, status
  end
end
