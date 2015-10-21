require "bunny"

module Twingly
  module AMQP
    class Connection
      attr_reader :connection

      def initialize(hosts: nil)
        @optional_hosts = hosts
        @connection     = create_connection
      end

      private

      def create_connection
        if ruby_env == "development"
          connection = Bunny.new
        else
          connection_options = {
            hosts: amqp_hosts,
            user: ENV.fetch("AMQP_USERNAME"),
            pass: ENV.fetch("AMQP_PASSWORD"),
            recover_from_connection_close: true,
            tls: tls?,
          }
          connection = Bunny.new(connection_options)
        end
        connection.start
        connection
      end

      def ruby_env
        ENV.fetch("RUBY_ENV")
      end

      def tls?
        ENV.has_key?("AMQP_TLS")
      end

      def amqp_hosts
        return @optional_hosts if @optional_hosts
        # Matches env keys like `RABBITMQ_01_HOST`
        environment_keys_with_host = ENV.keys.select { |key| key =~ /^rabbitmq_\d+_host$/i }
        environment_keys_with_host.map { |key| ENV[key] }
      end
    end
  end
end
