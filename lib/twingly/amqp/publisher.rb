module Twingly
  module AMQP
    module Publisher
      def publish(message)
        payload =
          if message.kind_of?(Array)
            message
          elsif message.respond_to?(:to_h)
            message.to_h
          else
            raise ArgumentError
          end

        json_payload = payload.to_json
        opts         = options.to_h
        @exchange.publish(json_payload, opts)
      end

      # only used by tests to avoid sleeping
      def publish_with_confirm(message)
        channel = @exchange.channel
        channel.confirm_select unless channel.using_publisher_confirmations?

        publish(message)

        @exchange.wait_for_confirms
      end

      def configure_publish_options
        yield options
      end

      private

      def options
        @options ||=
          OpenStruct.new(
            content_type: "application/json",
            persistent: true,
          )
      end
    end
  end
end
