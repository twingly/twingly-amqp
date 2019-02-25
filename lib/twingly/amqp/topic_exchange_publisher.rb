require "twingly/amqp/base_publisher"

module Twingly
  module AMQP
    class TopicExchangePublisher < BasePublisher
      def initialize(exchange_name:, routing_key: nil, connection: nil, opts: {})
        super(connection: connection)

        options.routing_key = routing_key

        @exchange = @connection.create_channel.topic(exchange_name, opts)
      end
    end
  end
end
