module Twingly
  module AMQP
    class DefaultExchangePublisher
      include Publisher

      DEFAULT_EXCHANGE = ""

      def initialize(queue_name:, connection: nil)
        options.routing_key = queue_name

        connection ||= Connection.instance
        @exchange = connection.create_channel.default_exchange
      end

      def self.delayed(delay_queue_name:, target_queue_name:, delay_ms:, connection: Connection.instance)
        Utilities.create_queue(delay_queue_name,
                               arguments: {
                                 "x-dead-letter-exchange":    DEFAULT_EXCHANGE,
                                 "x-dead-letter-routing-key": target_queue_name,
                               })

        new(queue_name: delay_queue_name, connection: connection).tap do |publisher|
          publisher.configure_publish_options do |options|
            options.expiration = delay_ms
          end
        end
      end
    end
  end
end
