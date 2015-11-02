module Twingly
  module AMQP
    class Session
      attr_reader :connection, :options

      def initialize(options = {})
        @options    = options
        @connection = create_connection
      end

      private

      def create_connection
        if ruby_env == "development"
          connection = Bunny.new
        else
          connection = Bunny.new(connection_options)
        end
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

      def ruby_env
        ENV.fetch("RUBY_ENV")
      end

      def tls?
        ENV.has_key?("AMQP_TLS")
      end

      def user_from_env
        ENV.fetch("AMQP_USERNAME")
      end

      def password_from_env
        ENV.fetch("AMQP_PASSWORD")
      end

      def hosts_from_env
        # Matches env keys like `RABBITMQ_01_HOST`
        environment_keys_with_host = ENV.keys.select { |key| key =~ /^rabbitmq_\d+_host$/i }
        environment_keys_with_host.map { |key| ENV[key] }
      end
    end
  end
end
