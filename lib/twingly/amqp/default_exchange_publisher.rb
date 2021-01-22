module Twingly
  module AMQP
    class DefaultExchangePublisher
      include Publisher

      def initialize(queue_name:, connection: Connection.instance)
        options.routing_key = queue_name

        @exchange = connection.create_channel.default_exchange
      end
    end
  end
end
