
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test-unit'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fluent/test'
require 'fluent/log'
require 'fluent/tls'
require 'fluent/test/helpers' 
require "fluent/test/driver/formatter"
require 'fluent/test/driver/output'


require 'fluent/plugin/formatter_rsyslog'
require 'fluent/plugin/out_rsyslog'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)


