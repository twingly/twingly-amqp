require "twingly/amqp/connection"
require "json"
require "ostruct"

module Twingly
  module AMQP
    class QueuePublisher
      def initialize(queue_name:, connection: nil)
        publish_options do |options|
          options.routing_key = queue_name
        end

        connection ||= Connection.instance
        @exchange = connection.create_channel.default_exchange
      end

      def publish(hash_payload)
        raise ArgumentError unless hash_payload.is_a?(Hash)

        payload = hash_payload.to_json
        options = @options.to_h

        @exchange.publish(payload, options)
      end

      def publish_options
        yield options
      end

      private

      def options
        @options ||=
          OpenStruct.new(
            content_type: "application/json",
            persistent: true,
          )

        @options
      end
    end
  end
end
