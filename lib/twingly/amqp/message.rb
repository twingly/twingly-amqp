module Twingly
  module AMQP
    class Message
      attr_reader :delivery_info, :metadata, :payload

      def initialize(delivery_info:, metadata:, payload:, channel:)
        @delivery_info = delivery_info
        @metadata      = metadata
        @payload       = parse_payload(payload)
        @channel       = channel
      end

      def ack
        @channel.ack(@delivery_info.delivery_tag)
      end

      def requeue
        @channel.reject(@delivery_info.delivery_tag, true)
      end

      def reject
        @channel.reject(@delivery_info.delivery_tag, false)
      end

      private

      def parse_payload(payload)
        JSON.parse(payload, symbolize_names: true)
      end
    end
  end
end
