
require_relative '../helper'

class SyslogFormatterTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup
    end

    CONFIG = %[
        @type syslog
    ]

    
    def create_driver(conf = CONFIG)
        Fluent::Test::Driver::Formatter.new(Fluent::Plugin::SyslogFormatter).configure(conf)
    end

    sub_test_case 'test zero config' do
        test 'test zero configuration with defaults' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            assert_equal "<13>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
                driver.instance.format(tag, time, record)
        end
        test 'test zero configuration with rfc5424 defaults' do
            driver = create_driver %(
                rfc5424 true
            )
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            assert_equal "<13>1 1970-01-01T00:00:00.123456+00:00 localhost fluentd - - - placeholder message\n",
                driver.instance.format(tag, time, record)
        end
        test 'test zero configuration with rfc6587 message size enabled' do
            driver = create_driver %(
                rfc6587 true
            )
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            formatted_message =  "<13>Jan 01 00:00:00 localhost fluentd[-]: placeholder message"
            message_size = formatted_message.length
            assert_equal "#{message_size} #{formatted_message}\n",
                driver.instance.format(tag, time, record)
        end
        test 'test zero configuration with rfc5424 syslog and rfc6587 message size enabled' do
            driver = create_driver %(
                rfc5424 true
                rfc6587 true
            )
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {}
            formatted_message =  "<13>1 1970-01-01T00:00:00.123456+00:00 localhost fluentd - - - placeholder message"
            message_size = formatted_message.length
            assert_equal "#{message_size} #{formatted_message}\n",
                driver.instance.format(tag, time, record)
        end
    end
        
    sub_test_case 'facility and severity' do
        test 'test facility' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {"facility" => "local0"} # local0 is 16 * 8 then default severity is info or 5 => 128 + 5 = 133
            assert_equal "<133>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
                driver.instance.format(tag, time, record)
        end
        test 'test severity' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {"severity" => "debug"} # debug severity is 7 with default user level facility of 1 => (1*8) + 5 = 15
            assert_equal "<15>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
                driver.instance.format(tag, time, record)
        end
        test 'test facility and severity empty values' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {"severity" => "", "facility" => ""} 
            assert_equal "<13>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
                driver.instance.format(tag, time, record)
        end
        test 'test facility and severity misconfigured' do
            driver = create_driver
            tag = "test-formatter"
            time = Fluent::EventTime.new(0, 123456000)
            record = {"severity" => "crowded", "facility" => "london tube"} 
            assert_equal "<13>Jan 01 00:00:00 localhost fluentd[-]: placeholder message\n",
                driver.instance.format(tag, time, record)
        end
    end
end