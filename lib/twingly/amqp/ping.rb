require "twingly/amqp/connection"
require "json"

module Twingly
  module AMQP
    class Ping
      VALID_PING_OPTIONS = [
        :automatic_ping,
        :provider_name,
        :source_ip,
        :priority,
        :url,
      ]

      def initialize(queue_name:, priority: nil, provider_name: nil, source_ip: nil, url_cache: NullCache, connection: nil)
        @url_cache = url_cache

        @provider_name = provider_name
        @queue_name    = queue_name
        @source_ip     = source_ip
        @priority      = priority

        connection ||= Connection.instance
        @channel = connection.create_channel
      end

      def ping(urls, options = {})
        Array(urls).each do |url|
          unless cached?(url)
            publish(url, options)
            cache!(url)

            yield url if block_given?
          end
        end
      end

      private

      def publish(url, options)
        payload = message(url, options).to_json
        @channel.default_exchange.publish(payload, amqp_publish_options)
      end

      def amqp_publish_options
        {
          key: @queue_name,
          persistent: true,
          content_type: "application/json",
        }
      end

      def message(url, options)
        ping_message = default_ping_message.merge(options)
        ping_message[:url] = url

        fail_on_invalid_ping_options(ping_message)
        fail_on_empty_ping_options(ping_message)

        ping_message
      end

      def default_ping_message
        {
          automatic_ping: false,
          provider_name:  @provider_name,
          source_ip:      @source_ip,
          priority:       @priority,
        }
      end

      def fail_on_invalid_ping_options(ping_message)
        invalid_option_keys = ping_message.keys - VALID_PING_OPTIONS
        unless invalid_option_keys.empty?
          fail ArgumentError, "Invalid options: #{invalid_option_keys}"
        end
      end

      def fail_on_empty_ping_options(ping_message)
        empty_option_keys = ping_message.select { |_, value| value.to_s.empty? }.keys
        unless empty_option_keys.empty?
          fail ArgumentError, "Options not set: #{empty_option_keys}"
        end
      end

      def cached?(url)
        @url_cache.cached?(url)
      end

      def cache!(url)
        @url_cache.cache!(url)
      end

      class NullCache
        def self.cached?(url)
          false
        end

        def self.cache!(url)
          # Do nothing
        end
      end
    end
  end
end
