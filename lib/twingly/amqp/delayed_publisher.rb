module Twingly
  module AMQP
    class DelayedPublisher
      include Publisher

      def initialize(delay_queue_name:, delay_ms:, target_exchange_name: "",
                     target_routing_key: "", connection: nil)
        if [target_exchange_name, target_routing_key].all?(&:empty?)
          raise ArgumentError, "At least one of target_exchange_name or " \
                               "target_routing_key must be set"
        end

        @target_routing_key   = target_routing_key
        @target_exchange_name = target_exchange_name

        connection ||= Connection.instance
        @channel     = connection.create_channel

        options.routing_key = delay_queue_name
        options.expiration  = delay_ms

        @channel.queue(delay_queue_name, queue_options)

        @exchange = @channel.default_exchange
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
          "x-dead-letter-exchange":    @target_exchange_name,
          "x-dead-letter-routing-key": @target_routing_key,
        }
      end
    end
  end
end
