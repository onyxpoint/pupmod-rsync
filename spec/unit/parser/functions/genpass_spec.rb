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
require 'fileutils'
require 'puppet'
require 'mocha'
require 'puppet/parser/functions/genpass'
RSpec.configure do |config|
  config.mock_with :mocha
end

function_class = Puppet::Parser::Functions.function(:genpass)
describe function_class do

  before :each do
    @scope = Puppet::Parser::Scope.new
    @testdir = File.join('/tmp',Time.now.to_i.to_s,'genpass_test')
    FileUtils.mkdir_p(@testdir)
    # Moving this since it's where the function pulls the directory
    # name from.
    Puppet[:vardir] = @testdir
  end

  it 'should require at least one variable' do
    expect {
      @scope.function_genpass()
    }.should raise_error Puppet::ParseError
    expect {
      @scope.function_genpass(['foo'])
    }.should_not raise_error
  end

  it 'should create the password file storage directory if it does not exist' do
    File.exists?("#{@testdir}/genpass").should be false
    @scope.function_genpass(['foo',12])
    File.exists?("#{@testdir}/genpass").should be true
  end

  it 'should require the ID option to be a string' do
    expect {
      @scope.function_genpass([000,15])
    }.should raise_error Puppet::ParseError
    expect {
      @scope.function_genpass(['000',15])
    }.should_not raise_error
  end

  it 'should require the length option to be an integer' do
    expect {
      @scope.function_genpass(['abc','15.5'])
    }.should raise_error Puppet::ParseError
    expect {
      @scope.function_genpass(['abc',15.5])
    }.should raise_error Puppet::ParseError
    expect {
      @scope.function_genpass(['abc',15])
    }.should_not raise_error
  end

  it 'should require the length option to be >= 6' do
    expect {
      @scope.function_genpass(['abc',4])
    }.should raise_error Puppet::ParseError
    expect {
      @scope.function_genpass(['abc',6])
    }.should_not raise_error
  end

  it 'should not contain any characters passed as the third option' do
    # This is difficult to test since the password is random!
    eliminate =  ('A'..'Z').to_a +
                 ('!'..'/').to_a +
                 (':'..'@').to_a +
                 ['[',']','^','_','{','}','~'] 
    eliminate.to_a.each do |check|
      result = @scope.function_genpass(['abc',15,eliminate])
      if result.include?(check) then
        raise "Spec: Result contains illegal characters!"
      end
    end
  end

  it 'should place a new password of the passed length into a file with the same name as the ID' do
    passlen = 343
    @scope.function_genpass(['abc',passlen])
    @scope.function_genpass(['abc']).length.should == passlen
  end

  it 'should create a backup file if the length is different from the previous password' do
    @scope.function_genpass(['abc',20])
    @scope.function_genpass(['abc',21])
    File.exists?("#{@testdir}/genpass/abc.old").should be true
  end

  it 'should return the generated password' do
    @scope.function_genpass(['abc',20]).should be_a String
  end

  it 'should return the password in the file if the password file exists and the length is the same' do
    origpass = @scope.function_genpass(['abc',20])
    @scope.function_genpass(['abc',20]).should == origpass
  end

  after :each do
    FileUtils.rm_rf(File.dirname(@testdir))
  end
end
