module Twingly
  module AMQP
    class DelayedDefaultExchangePublisher
      include Publisher

      def initialize(target_queue_name:, delay_ms:, connection: nil)
        @target_queue_name = target_queue_name
        delay_queue_name = "#{target_queue_name}.delayed"

        options.routing_key = delay_queue_name
        options.expiration  = delay_ms

        connection ||= Connection.instance
        channel      = connection.create_channel

        channel.queue(delay_queue_name, queue_options)

        @exchange = channel.default_exchange
      end

      private

      def queue_options
        {
          durable: true,
          arguments: queue_arguments,
        }
      end

      def queue_arguments
        {
          "x-dead-letter-exchange": "",
          "x-dead-letter-routing-key": @target_queue_name,
        }
      end
    end
  end
end
