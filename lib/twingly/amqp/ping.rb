require "twingly/amqp/connection"
require "json"

module Twingly
  module AMQP
    class Ping
      def initialize(provider_name:, queue_name:, source_ip:, priority:, url_cache: NullCache, connection: nil)
        @url_cache = url_cache

        @provider_name = provider_name
        @queue_name    = queue_name
        @source_ip     = source_ip
        @priority      = priority

        connection ||= Connection.new.connection
        @channel = connection.create_channel
      end

      def ping(urls)
        Array(urls).each do |url|
          unless cached?(url)
            publish(url)
            cache!(url)

            yield url if block_given?
          end
        end
      end

      private

      def publish(url)
        payload = message(url).to_json
        @channel.default_exchange.publish(payload, options)
      end

      def options
        {
          key: @queue_name,
          persistent: true,
          content_type: "application/json",
        }
      end

      def message(url)
        {
          automatic_ping: false,
          provider_name: @provider_name,
          priority: @priority,
          source_ip: @source_ip,
          url: url,
        }
      end

      def cached?
        @url_cache.cached?
      end

      def cache!
        @url_cache.cache!
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
