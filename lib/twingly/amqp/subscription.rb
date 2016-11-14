require "twingly/amqp/connection"
require "twingly/amqp/message"

module Twingly
  module AMQP
    class Subscription
      def initialize(queue_name:, exchange_topic: nil, routing_key: nil, consumer_threads: 4, prefetch: 20, connection: nil)
        @queue_name       = queue_name
        @exchange_topic   = exchange_topic
        @routing_key      = routing_key
        @consumer_threads = consumer_threads
        @prefetch         = prefetch

        connection ||= Connection.instance
        @channel = create_channel(connection)
        @queue   = @channel.queue(@queue_name, queue_options)

        if @exchange_topic && @routing_key
          exchange = @channel.topic(@exchange_topic, durable: true)
          @queue.bind(exchange, routing_key: @routing_key)
        end

        @before_handle_message_callback = proc {}
        @on_exception_callback          = proc {}
      end

      def each_message(&block)
        setup_traps

        consumer = @queue.subscribe(subscribe_options) do |delivery_info, metadata, payload|
          @before_handle_message_callback.call(payload)

          message = Message.new(
            delivery_info: delivery_info,
            metadata:      metadata,
            payload:       payload,
            channel:       @channel,
          )

          block.call(message)
        end

        # The consumer isn't blocking, so we wait here
        sleep 0.5 until cancel?

        consumer.cancel
      end

      def before_handle_message(&block)
        @before_handle_message_callback = block
      end

      def on_exception(&block)
        @on_exception_callback = block
      end

      def cancel?
        @cancel
      end

      def cancel!
        @cancel = true
      end

      private

      def create_channel(connection)
        channel = connection.create_channel(nil, @consumer_threads)
        channel.prefetch(@prefetch)
        channel.on_uncaught_exception do |exception, _|
          @on_exception_callback.call(exception)
        end
        channel
      end

      def queue_options
        {
          durable: true,
        }
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

      def setup_traps
        [:INT, :TERM].each do |signal|
          Signal.trap(signal) do
            # Exit fast if we've already got a signal since before
            exit!(true) if cancel?

            # Set cancel flag, cancels consumers
            cancel!
          end
        end
      end
    end
  end
end
