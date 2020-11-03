module Twingly
  module AMQP
    class DefaultExchangePublisher
      include Publisher

      def initialize(queue_name:, connection: nil)
        options.routing_key = queue_name

        connection ||= Connection.instance
        @exchange = connection.create_channel.default_exchange
      end
    end
  end
end
