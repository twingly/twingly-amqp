module Twingly
  module AMQP
    class PingOptions
      attr_accessor :provider_name, :source_ip, :priority

      attr_reader :custom_options

      REQUIRED_OPTIONS = %i[provider_name source_ip priority]

      def initialize(provider_name: nil, source_ip: nil, priority: nil,
                     custom_options: {})
        self.provider_name  = provider_name
        self.source_ip      = source_ip
        self.priority       = priority
        self.custom_options = custom_options

        yield self if block_given?
      end

      def custom_options=(options)
        unless options.respond_to?(:to_h)
          raise ArgumentError, "Options must respond to 'to_h'"
        end

        @custom_options = options.to_h
      end

      def to_h
        {
          provider_name:  provider_name,
          source_ip:      source_ip,
          priority:       priority,
          custom_options: custom_options,
        }
      end

      def validate
        missing_keys = to_h.select do |key, value|
          REQUIRED_OPTIONS.include?(key) && value.to_s.empty?
        end.keys

        if missing_keys.any?
          raise ArgumentError, "Required options not set: #{missing_keys}"
        end
      end

      def merge(other)
        PingOptions.new do |options|
          options.provider_name  = other.provider_name || provider_name
          options.source_ip      = other.source_ip     || source_ip
          options.priority       = other.priority      || priority
          options.custom_options = custom_options.merge(other.custom_options)
        end
      end
    end
  end
end
