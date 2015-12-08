module Twingly
  module AMQP
    class PingOptions
      attr_accessor :provider_name, :source_ip, :priority

      def initialize(provider_name: nil, source_ip: nil, priority: nil)
        self.provider_name = provider_name
        self.source_ip     = source_ip
        self.priority      = priority

        yield self if block_given?
      end

      def to_h
        {
          automatic_ping: false,
          provider_name:  provider_name,
          source_ip:      source_ip,
          priority:       priority,
        }
      end

      def validate
        missing_keys = to_h.select { |_, value| value.to_s.empty? }.keys
        if missing_keys.any?
          fail ArgumentError, "Required options not set: #{missing_keys}"
        end
      end

      def merge(other)
        PingOptions.new do |options|
          options.provider_name = other.provider_name || provider_name
          options.source_ip     = other.source_ip     || source_ip
          options.priority      = other.priority      || priority
        end
      end
    end
  end
end
