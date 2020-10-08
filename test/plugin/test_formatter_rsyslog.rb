
require_relative '../helper'

class SyslogFormatterTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup
    end

    CONFIG = %[
        @type rsyslog
    ]

    
    def create_driver(conf = CONFIG)
        Fluent::Test::Driver::Formatter.new(Fluent::Plugin::SyslogFormatter).configure(conf)
    end

    sub_test_case 'test zero config' do
        test 'to test zeroconfiguration formatter' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            assert_equal "<13>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
            #assert_equal "<13>1 1970-01-01T00:00:00.123456+00:00 localhost fluentd - - - placeholder message\n",
                 driver.instance.format(tag, time, record)
        end
    end
end