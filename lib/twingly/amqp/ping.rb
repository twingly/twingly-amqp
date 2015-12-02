require "twingly/amqp/connection"
require "json"

module Twingly
  module AMQP
    class Ping
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
        provider_name = options.fetch(:provider_name) { @provider_name }
        source_ip     = options.fetch(:source_ip)     { @source_ip }
        priority      = options.fetch(:priority)      { @priority }

        raise_missing_argument_error(:provider_name) unless provider_name
        raise_missing_argument_error(:source_ip)     unless source_ip
        raise_missing_argument_error(:priority)      unless priority

        {
          automatic_ping: false,
          provider_name:  provider_name,
          source_ip:      source_ip,
          priority:       priority,
          url:            url,
        }
      end

      def raise_missing_argument_error(argument_name)
        raise ArgumentError, "#{argument_name} not specified"
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
