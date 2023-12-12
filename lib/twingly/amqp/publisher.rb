module Twingly
  module AMQP
    module Publisher
      def publish(message, opts = {})
        payload =
          if message.kind_of?(Array)
            message
          elsif message.respond_to?(:to_h)
            message.to_h
          else
            raise ArgumentError
          end

        json_payload       = payload.to_json
        publishing_options = options.to_h.merge(opts)
        @exchange.publish(json_payload, publishing_options)
      end

      # Only used by tests to lessen the time we need to sleep
      def publish_with_confirm(message, opts = {})
        channel = @exchange.channel
        channel.confirm_select unless channel.using_publisher_confirmations?

        publish(message, opts)

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
