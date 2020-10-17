require 'fluent/plugin/formatter'

module Fluent::Plugin
    class SyslogFormatter < Formatter
        Fluent::Plugin.register_formatter('rsyslog', self)

        FormatRFC5424 = "<%d>1 %s %s %s %s %s %s %s"
        FormatRFC3164 = "<%d>%s %s %s[%s]: %s"

        FACILITY_INDEX = {
            'kern'       => 0,
            'user'       => 1,
            'mail'       => 2,
            'daemon'     => 3,
            'auth'       => 4,
            'syslog'     => 5,
            'lpr'        => 6,
            'news'       => 7,
            'uucp'       => 8,
            'cron'       => 9,
            'authpriv'   => 10,
            'ftp'        => 11,
            'ntp'        => 12,
            'audit'      => 13,
            'alert'      => 14,
            'at'         => 15,
            'local0'     => 16,
            'local1'     => 17,
            'local2'     => 18,
            'local3'     => 19,
            'local4'     => 20,
            'local5'     => 21,
            'local6'     => 22,
            'local7'     => 23
        }

        SEVERITY_INDEX = {
            'emerg'   => 0,
            'alert'   => 1,
            'crit'    => 2,
            'err'     => 3,
            'warn'    => 4,
            'notice'  => 5,
            'info'    => 6,
            'debug'   => 7
        }

        desc 'facility label for syslog message'
        config_param :facility, :string, default: "facility"
        desc 'severity label for syslog message'
        config_param :severity, :string, default: "severity"
        desc 'source host for syslog message.'
        config_param :host, :string, default: "host"
        desc 'program name for syslog message.'
        config_param :program, :string, :default => "program"
        desc 'process id for syslog message.'
        config_param :pid, :string, default: "pid"
      desc 'message id for syslog message.'
      config_param :msgid, :string, default: "msgid"
      desc 'extra parameters for syslog'
      config_param :sd, :string, default: "sd"
      desc 'message text to log.'
      config_param :message, :string, default: "message"
      desc 'syslog message format: default is BSD syslog, however this allows for RFC5424'
      config_param :rfc5424, :bool, default: false
      desc 'prepend message length to syslog line'
      config_param :rfc6587, :bool, default: false

      def configure(conf)
          super
          @facility_list = @facility.split(".")
          @severity_list = @severity.split(".")
          @host_list = @host.split(".")
          @program_list = @program.split(".")
          @pid_list = @pid.split(".")
          @msgid_list = @msgid.split(".")
          @sd_list = @sd.split(".")
       @message_list = @message.split(".")
      end

      def format(tag, time, record)
          log.debug("Record")
          log.debug(record.map { |k, v| "#{k}=#{v}" }.join('&'))
          msg = format_syslog(
              facility: record.dig(*@facility_list) || "user",
              severity: record.dig(*@severity_list) || "notice",
              time: time,
              host: record.dig(*@host_list) || "localhost",
              program: record.dig(*@program_list) || "fluentd",
              pid: record.dig(*@pid_list) || "-",
              msgid: record.dig(*@msgid_list) || "-",
              sd: record.dig(*@sd_list) || "-",
              message: record.dig(*@message_list) || "placeholder message"
          )

          return msg + "\n" unless @rfc6587
          msg.length.to_s + ' ' + msg + "\n"
      end

      private

      def format_syslog(facility:, severity:, time:, host:, program: , pid: , msgid:, sd: , message:)
          return FormatRFC5424 % [get_priority(facility, severity), format_time(time), host[0..254], program[0..47], pid[0..127], msgid[0..31], sd, message] if @rfc5424
              
          FormatRFC3164 % [get_priority(facility, severity), format_time(time), host[0..254], program[0..32], pid[0..127], message]
      end

      def format_time(timestamp)
          timestamp = Time.new if timestamp.nil?
          if rfc5424
              return Time.at(timestamp.to_r).utc.to_datetime.rfc3339(6) if timestamp.is_a?(Fluent::EventTime)
              DateTime.strptime(timestamp.to_s, '%s').rfc3339(6)
          else 
              return Time.at(timestamp.to_r).utc.strftime("%b %d %H:%M:%S") if timestamp.is_a?(Fluent::EventTime)
              timestamp.strftime("%b %d %H:%M:%S")
          end
      end

      def get_priority(facility, severity)
          facility = "user" unless FACILITY_INDEX.key?(facility)
          severity = "notice" unless SEVERITY_INDEX.key?(severity)

          (FACILITY_INDEX[facility] * 8) + SEVERITY_INDEX[severity]
      end

    end
end
