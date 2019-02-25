require "twingly/amqp/base_publisher"

module Twingly
  module AMQP
    class DefaultExchangePublisher < BasePublisher
      def initialize(queue_name:, connection: nil)
        super(connection: connection)

        options.routing_key = queue_name

        @exchange = @connection.create_channel.default_exchange
      end
    end
  end
end
