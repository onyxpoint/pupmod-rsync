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
module Puppet::Parser::Functions
  newfunction(:genpass, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Generates, stores, and retrieves passwords of various lengths.
    If you specify a different length password than the existing password then
    a new password will be generated.

    Options:

      genpass(
        ID        -> The name of the target file: String : Mandatory,
        [length]  -> The length of the password: Integer : Optional (default=20),
        [skip]    -> Characters to never include in your password: Array : Optional
      )

    Examples:

      # Basic Usage
      $passwd = genpass('foo', 32)
      # Eliminating specific characters from your passwords. '\',"'",
      # "`", and '"' will never be included.
      $passwd = genpass('foo', 32, ['$','@','/'])
      # Get a previously generated password returned or generate a
      # password with the default length of 20.
      $passwd = genpass('foo')

    ENDHEREDOC

    require 'fileutils'

    passchars = ('a'..'z').to_a +
      ('A'..'Z').to_a +
      ('!'..'/').to_a +
      (':'..'@').to_a +
      ['[',']','^','_','{','}','~'] -
      ['\\','"',"'",'`']

    # Make sure we have the correct number of arguments.
    if not args
      raise Puppet::ParseError,
            'genpass(): Usage - genpass("<unique ID>", <password length>), [<array of characters to exclude>]'
    end

    # If the holding directory doesn't exist, then create it.
    genpass_dir = "#{Puppet[:vardir]}/genpass"
    if not File.directory?(genpass_dir) then
      FileUtils.mkdir_p(genpass_dir)
      FileUtils.chmod(0750,genpass_dir)
    end

    if not args.first.class == String then
      raise Puppet::ParseError,
            "genpass(): <unique ID> must be a String"
    end
    genpass_target = "#{genpass_dir}/#{args.shift}"

    genpass_length = args.shift
    if not genpass_length.nil? then
      begin
        genpass_length = Integer(genpass_length.to_s)
      rescue
        raise Puppet::ParseError,
              "genpass(): <password length> must be an Integer"
      end
      if genpass_length < 6 then
        raise Puppet::ParseError, 
              "genpass(): <password length> must be >= 6"
      end
    else
      # The default password length is 20.
      genpass_length_default = true
      genpass_length = 20
    end

    genpass_chars = passchars - Array(args.shift)

    # If we currently have a file and the password is the same
    # length, or we were not passed a length, then return the
    # current password.
    if File.exists?(genpass_target) then
      if genpass_length_default or ((File.stat(genpass_target).size - 1) == genpass_length) then
        return File.read(genpass_target).chomp
      else
        FileUtils.mv(genpass_target, "#{genpass_target}.old")
      end
    end

    # Generate a new random password of length genpass_length
    newpass = String.new
    while newpass.length < genpass_length do
      newpass += genpass_chars[rand(genpass_chars.length)]
    end

    fd = File.open(genpass_target,'w')
    fd.puts(newpass)
    fd.close

    return newpass
  end
end
