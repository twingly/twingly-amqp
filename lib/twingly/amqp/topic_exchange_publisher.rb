module Twingly
  module AMQP
    class TopicExchangePublisher
      include Publisher

      def initialize(exchange_name:, routing_key: nil, connection: Connection.instance, opts: {})
        options.routing_key = routing_key

        @exchange = connection.create_channel.topic(exchange_name, opts)
      end
    end
  end
end
