module Twingly
  module AMQP
    class Subscription
      def initialize(queue_name:, exchange_topic:, routing_key:, consumer_threads: 4, prefetch: 20, connection: nil)
        @queue_name       = queue_name
        @exchange_topic   = exchange_topic
        @routing_key      = routing_key
        @consumer_threads = consumer_threads
        @prefetch         = prefetch

        connection ||= Connection.new.connection
        @channel = create_channel(connection)

        @before_handle_message_callback = Proc.new {}
        @on_exception_callback          = Proc.new {}
      end

      def subscribe(&block)
        queue    = @channel.queue(@queue_name, queue_options)
        exchange = @channel.topic(@exchange_topic, durable: true)
        queue.bind(exchange, routing_key: @routing_key)

        setup_traps

        consumer = queue.subscribe(subscribe_options) do |delivery_info, metadata, payload|
          begin
            @before_handle_message_callback.call(payload)

            handle_message_payload(payload, &block)

            @channel.ack(delivery_info.delivery_tag)
          rescue
            @channel.reject(delivery_info.delivery_tag)
            raise
          end
        end

        # The consumer isn't blocking, so we wait here
        until cancel? do
          sleep 0.5
        end

        puts "Shutting down" if development?
        consumer.cancel
      end

      def before_handle_message(&block)
        @before_handle_message_callback = block
      end

      def on_exception(&block)
        @on_exception_callback = block
      end

      private

      def create_channel(connection)
        channel = connection.create_channel(nil, @consumer_threads)
        channel.prefetch(@prefetch)
        channel.on_uncaught_exception do |exception, _|
          puts exception.message, exception.backtrace if development?
          @on_exception_callback.call(exception)
        end
        channel
      end

      def development?
        ruby_env == "development"
      end

      def ruby_env
        ENV.fetch("RUBY_ENV")
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
        tag_name = [Socket.gethostname, ruby_env].join('-')
        @channel.generate_consumer_tag(tag_name)
      end

      def cancel?
        @cancel
      end

      def cancel!
        @cancel = true
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

      def handle_message_payload(payload, &block)
        messages = parse_message_payload(payload)

        messages.each do |message|
          block.call(message)
        end
      end

      def parse_message_payload(payload)
        result = JSON.parse(payload, symbolize_names: true)

        if result.is_a?(Array)
          result
        else
          [result]
        end
      end
    end
  end
end
