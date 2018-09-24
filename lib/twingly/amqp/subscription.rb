require "twingly/amqp/connection"
require "twingly/amqp/message"

module Twingly
  module AMQP
    class Subscription
      def initialize(queue_name:, exchange_topic: nil, routing_key: nil,
                     routing_keys: nil, consumer_threads: 4, prefetch: 20,
                     connection: nil, max_length: nil)
        @queue_name       = queue_name
        @exchange_topic   = exchange_topic
        @routing_keys     = Array(routing_keys || routing_key)
        @consumer_threads = consumer_threads
        @prefetch         = prefetch
        @max_length       = max_length

        unless routing_key.nil?
          warn "[DEPRECATION] `routing_key` is deprecated. "\
               "Please use `routing_keys` instead."
        end

        connection ||= Connection.instance
        @channel = create_channel(connection)
        @queue   = @channel.queue(@queue_name, queue_options)

        if @exchange_topic && @routing_keys.any?
          exchange = @channel.topic(@exchange_topic, durable: true)

          @routing_keys.each do |routing_key|
            @queue.bind(exchange, routing_key: routing_key)
          end
        end

        @before_handle_message_callback = proc {}
        @on_exception_callback          = proc {}
      end

      def each_message(blocking: true, &block)
        consumer = create_consumer(&block)

        if blocking
          sleep 0.01 until cancel?

          consumer.cancel
        end
      end

      def before_handle_message(&block)
        @before_handle_message_callback = block
      end

      def on_exception(&block)
        @on_exception_callback = block
      end

      def message_count
        @queue.status.fetch(:message_count)
      end

      def raw_queue
        @queue
      end

      def cancel?
        @cancel
      end

      def cancel!
        @cancel = true
      end

      private

      def create_consumer
        @queue.subscribe(subscribe_options) do |delivery_info, metadata, payload|
          @before_handle_message_callback.call(payload)

          message = Message.new(
            delivery_info: delivery_info,
            metadata:      metadata,
            payload:       payload,
            channel:       @channel,
          )

          yield message
        end
      end

      def create_channel(connection)
        channel = connection.create_channel(nil, @consumer_threads)
        channel.prefetch(@prefetch)
        channel.on_uncaught_exception do |exception, _|
          Twingly::AMQP.configuration.logger.error(exception)
          @on_exception_callback.call(exception)
        end
        channel
      end

      def queue_options
        {
          durable: true,
          arguments: queue_arguments,
        }
      end

      def queue_arguments
        {}.tap do |arguments|
          arguments["x-max-length"] = @max_length if @max_length
        end
      end

      def subscribe_options
        {
          manual_ack:   true,
          consumer_tag: consumer_tag,
        }
      end

      def consumer_tag
        tag_name = Socket.gethostname
        @channel.generate_consumer_tag(tag_name)
      end
    end
  end
end
