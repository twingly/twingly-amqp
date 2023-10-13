module Twingly
  module AMQP
    module Utilities
      def self.create_queue(queue_name, durable: true, arguments: {}, queue_type: :quorum, connection: Connection.instance)
        connection.with_channel do |channel|
          case queue_type
          when :quorum
            # Quorum queues are always durable, see https://www.rabbitmq.com/quorum-queues.html#feature-matrix
            raise ArgumentError, "durable: false is not supported by quorum queues" unless durable

            return channel.quorum_queue(queue_name, arguments: arguments)
          when :classic
            return channel.queue(queue_name, durable: durable, arguments: arguments)
          else
            raise ArgumentError, "Unknown queue type '#{queue_type}'"
          end
        end
      end
    end
  end
end
