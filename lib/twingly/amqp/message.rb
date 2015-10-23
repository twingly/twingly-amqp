require "json"

module Twingly
  module AMQP
    class Message
      ACK     = :ack
      REQUEUE = :requeue
      DISCARD = :discard

      attr_accessor :status, :delivery_info, :metadata, :payload

      def initialize(delivery_info:, metadata:, payload:)
        @delivery_info = delivery_info
        @metadata      = metadata
        @payload       = payload

        @status = :ack

        yield self if block_given?
      end

      def ack
        status = ACK
      end

      def requeue
        status = REQUEUE
      end

      def discard
        status = DISCARD
      end

      def ack?
        status == ACK
      end

      def requeue?
        status == REQUEUE
      end

      def discard?
        status == DISCARD
      end
    end
  end
end
