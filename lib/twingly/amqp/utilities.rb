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

      # Bunny 3 stores errors that stop its reader loop instead of raising them, so a dead
      # connection still looks open. The error is left in place so every caller fails, and a
      # copy is raised so each one gets its own backtrace.
      def self.raise_if_connection_failed(connection)
        return unless defined?(Bunny::ExceptionAccumulator) && connection.respond_to?(:session_error_handler)

        handler = connection.session_error_handler
        return unless handler.is_a?(Bunny::ExceptionAccumulator)

        error = handler.all.first
        raise error.dup if error
      end
    end
  end
end
