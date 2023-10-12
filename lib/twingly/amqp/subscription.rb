module Twingly
  module AMQP
    class Subscription
      def initialize(queue_name:, exchange_topic: nil, routing_key: nil,
                     routing_keys: nil, consumer_threads: 1, prefetch: 20,
                     connection: Connection.instance, max_length: nil,
                     queue_type: :quorum)
        @queue_name       = queue_name
        @exchange_topic   = exchange_topic
        @routing_keys     = Array(routing_keys || routing_key)
        @consumer_threads = consumer_threads
        @prefetch         = prefetch
        @max_length       = max_length
        @queue_type       = queue_type
        @cancel           = false
        @consumer         = nil
        @blocking         = false

        if routing_key
          warn "[DEPRECATION] `routing_key` is deprecated. "\
               "Please use `routing_keys` instead."
        end

        @channel = create_channel(connection)
        @queue   = create_queue

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
        @blocking = blocking
        @consumer = create_consumer(&block)

        if @blocking
          sleep 0.01 until cancel?

          @consumer.cancel
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
        @consumer.cancel unless @blocking
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

      def create_queue
        case @queue_type
        when :quorum
          @channel.quorum_queue(@queue_name, queue_options)
        when :classic
          @channel.queue(@queue_name, queue_options)
        else
          raise ArgumentError, "Unknown queue type #{@queue_type}"
        end
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
