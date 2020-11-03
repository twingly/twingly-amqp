module Twingly
  module AMQP
    class TopicExchangePublisher
      include Publisher

      def initialize(exchange_name:, routing_key: nil, connection: nil, opts: {})
        options.routing_key = routing_key

        connection ||= Connection.instance
        @exchange = connection.create_channel.topic(exchange_name, opts)
      end
    end
  end
end
