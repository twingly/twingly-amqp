require "twingly/amqp/connection"
require "twingly/amqp/ping_options"
require "json"

module Twingly
  module AMQP
    class Pinger
      def initialize(queue_name:, ping_expiration: nil, url_cache: NullCache, connection: nil)
        @queue_name = queue_name
        @url_cache  = url_cache

        connection ||= Connection.instance
        @channel = connection.create_channel

        @ping_expiration      = ping_expiration
        @default_ping_options = PingOptions.new
      end

      def ping(urls, options_hash = {})
        options = PingOptions.new(options_hash)
        options = @default_ping_options.merge(options)

        options.validate

        Array(urls).each do |url|
          unless cached?(url)
            publish(url, options)
            cache!(url)

            yield url if block_given?
          end
        end
      end

      def default_ping_options
        yield @default_ping_options
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
          expiration: @ping_expiration,
        }
      end

      def message(url, options)
        ping_message = options.to_h
        ping_message[:url] = url

        ping_message
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
