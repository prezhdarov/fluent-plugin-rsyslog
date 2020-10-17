require "fluent/tls"

require 'fluent/plugin/output'


module Fluent::Plugin
    class SyslogOutput < Output
        Fluent::Plugin.register_output('rsyslog', self)
     
           # Enable threads if you are writing an async buffered plugin.
           helpers :socket, :formatter

           DEFAULT_FORMATTER = "rsyslog"

           desc 'syslog server address to connect to.'
           config_param :host, :string, default: nil
           desc 'syslog server port to connect to.'
           config_param :port, :integer, default: 5140
           desc 'syslog server protocol. you can choose between udp, tcp and ssl/tls over tcp'
           config_param :transport, :enum, list: [:udp, :tcp, :tls], default: 'udp'
           desc 'The timeout time when sending event logs.'
           
           # Socket options
           config_param :send_timeout, :time, default: 60
           desc 'The timeout time for socket connect'
           config_param :connect_timeout, :time, default: nil
           ## The reason of default value of :ack_response_timeout:
           # Linux default tcp_syn_retries is 5 (in many environment)
           # 3 + 6 + 12 + 24 + 48 + 96 -> 189 (sec)
           desc 'This option is used when is true.'
           config_param :recv_timeout, :time, default: 190
           
           # TLS options - taken from out_forward plugin
           desc 'The default version of TLS transport.'
           config_param :tls_version, :enum, list: Fluent::TLS::SUPPORTED_VERSIONS, default: Fluent::TLS::DEFAULT_VERSION
           desc 'The cipher configuration of TLS transport.'
           config_param :tls_ciphers, :string, default: Fluent::TLS::CIPHERS_DEFAULT
           desc 'Skip all verification of certificates or not.'
           config_param :tls_insecure_mode, :bool, default: false
           desc 'Allow self signed certificates or not.'
           config_param :tls_allow_self_signed_cert, :bool, default: false
           desc 'Verify hostname of servers and certificates or not in TLS transport.'
           config_param :tls_verify_hostname, :bool, default: true
           desc 'The additional CA certificate path for TLS.'
           config_param :tls_ca_cert_path, :array, value_type: :string, default: nil
           desc 'The additional certificate path for TLS.'
           config_param :tls_cert_path, :array, value_type: :string, default: nil
           desc 'The client certificate path for TLS.'
           config_param :tls_client_cert_path, :string, default: nil
           desc 'The client private key path for TLS.'
           config_param :tls_client_private_key_path, :string, default: nil
           desc 'The client private key passphrase for TLS.'
           config_param :tls_client_private_key_passphrase, :string, default: nil, secret: true


           config_section :format do
               config_set_default :@type, DEFAULT_FORMATTER
           end

           def configure(config)
               super
               @sockets = {}
               @formatter = formatter_create
           end
           
           #def multi_workers_ready?
           # true
           #end
           
           def close
               super
               @sockets.each_value { |s| s.close }
               @sockets = {}
           end

           def write(chunk)
               socket = get_socket(@transport.to_sym, @host, @port)
               tag = chunk.metadata.tag
               chunk.each do |time, record|
                   begin
                       socket.write @formatter.format(tag, time, record)
                       IO.select(nil, [socket], nil, 1) || raise(StandardError.new "ReconnectError")
                   rescue => e
                       @sockets.delete(socketid(@transport.to_sym, @host, @port))
                       socket.close
                   raise
                   end
               end
           end

           private

           def get_socket(transport, host, port)
                socket = @sockets[socketid(transport, host, port)]
                return socket if socket

                @sockets[socketid(transport, host, port)] = socket_create(transport.to_sym, host, port, socket_options)
                       
           end

           def socket_options
                generic_options = {
                    nonblock: true,
                    linger_timeout: @send_timeout,
                    send_timeout: @send_timeout,
                    recv_timeout: @recv_timeout,
                    connect_timeout: @connect_timeout
                }
                case @transport
                when :tcp
                    return generic_options
                when :udp
                    return generic_options.merge!({"connect" => true})
                when :tls
                    return generic_options.merge!({
                        version: @tls_version,
                        ciphers: @tls_ciphers,
                        insecure: @tls_insecure,
                        verify_fqdn: @tls_verify_hostname,
                        #fqdn: hostname,
                        allow_self_signed_cert: @tls_allow_self_signed_cert,
                        cert_paths: @tls_ca_cert_path
                        #cert_path: @tls_client_cert_path,
                        #private_key_path: @tls_client_private_key_path,
                        #private_key_passphrase: @tls_client_private_key_passphrase,
                        #cert_thumbprint: @tls_cert_thumbprint,
                        #cert_logical_store_name: @tls_cert_logical_store_name,
                        #cert_use_enterprise_store: @tls_cert_use_enterprise_store
                    })
                else
                    raise "BUG: unknown transport protocol #{@transport}"
                end
           end

           def socketid(transport, host, port)
               "#{host}:#{port}:#{transport}"
           end
    
    end
end

