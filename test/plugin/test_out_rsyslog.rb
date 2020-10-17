
require_relative '../helper'

class SyslogOutputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup
        @time = Fluent::EventTime.new(0, 123456)
        @formatted_log = "51 <14>1 1970-01-01T00:00:00.000123+00:00 - - - - - hi"
    end

    CONFIG = %[
        @type syslog
        host localhost
        port 1514
    ]

    def create_driver(conf = CONFIG)
        Fluent::Test::Driver::Output.new(Fluent::Plugin::SyslogOutput).configure(conf)
    end


    sub_test_case 'test config' do
        test 'test host and port are set' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            assert_equal "localhost", driver.instance.host
            assert_equal 1514, driver.instance.port
        end
    end

end

