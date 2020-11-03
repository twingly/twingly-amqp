module Twingly
  module AMQP
    class Session
      attr_reader :connection, :options

      DEFAULT_USER  = "guest".freeze
      DEFAULT_PASS  = "guest".freeze
      DEFAULT_HOSTS = ["localhost"].freeze

      def initialize(options = {})
        @options    = options
        @connection = create_connection
      end

      private

      def create_connection
        connection = Bunny.new(connection_options)
        connection.start
        connection
      end

      def connection_options
        options[:user]  ||= user_from_env
        options[:pass]  ||= password_from_env
        options[:hosts] ||= hosts_from_env

        default_connection_options.merge(options)
      end

      def default_connection_options
        {
          tls: tls?,
        }
      end

      def tls?
        ENV.key?("AMQP_TLS")
      end

      def user_from_env
        ENV.fetch("AMQP_USERNAME") { DEFAULT_USER }
      end

      def password_from_env
        ENV.fetch("AMQP_PASSWORD") { DEFAULT_PASS }
      end

      def hosts_from_env
        # Matches env keys like `RABBITMQ_01_HOST`
        environment_keys_with_host = ENV.keys.select do |key|
          key =~ /^rabbitmq_\d+_host$/i
        end
        hosts = environment_keys_with_host.map { |key| ENV[key] }

        return DEFAULT_HOSTS if hosts.empty?

        hosts
      end
    end
  end
end
