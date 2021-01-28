module Twingly
  module AMQP
    module Utilities
      def self.create_queue(queue_name, durable: true, arguments: {}, connection: Connection.instance)
        connection.with_channel do |channel|
          channel.queue(
            queue_name,
            durable: durable,
            arguments: arguments,
          )
        end
      end
    end
  end
end
