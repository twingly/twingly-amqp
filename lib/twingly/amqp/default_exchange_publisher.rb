module Twingly
  module AMQP
    class DefaultExchangePublisher
      include Publisher

      def initialize(queue_name:, connection: nil)
        options.routing_key = queue_name

        connection ||= Connection.instance
        @exchange = connection.create_channel.default_exchange
      end

      def self.delayed(delay_queue_name:, delay_ms:, target_exchange_name: "",
                       target_routing_key: "", connection: Connection.instance)
        if [target_exchange_name, target_routing_key].all?(&:empty?)
          raise ArgumentError, "At least one of target_exchange_name or " \
                                "target_routing_key must be set"
        end

        Utilities.create_queue(delay_queue_name,
                               arguments: {
                                 "x-dead-letter-exchange":    target_exchange_name,
                                 "x-dead-letter-routing-key": target_routing_key,
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
