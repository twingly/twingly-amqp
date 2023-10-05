module Twingly
  module AMQP
    module Utilities
      def self.create_queue(queue_name, durable: true, arguments: {}, queue_type: :classic, connection: Connection.instance)
        connection.with_channel do |channel|
          case queue_type
          when :classic
            return channel.queue(queue_name, durable: durable, arguments: arguments)
          when :quorum
            return channel.quorum_queue(queue_name, arguments: arguments)
          else
            raise ArgumentError, "Unknown queue type '#{queue_type}'"
          end
        end
      end
    end
  end
end
