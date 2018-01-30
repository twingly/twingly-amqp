require "twingly/amqp/connection"
require "twingly/amqp/ping_options"
require "twingly/amqp/default_exchange_publisher"
require "json"

module Twingly
  module AMQP
    class Pinger
      def initialize(queue_name:, ping_expiration: nil, url_cache: NullCache, connection: nil, confirm_publish: false)
        @url_cache = url_cache
        connection ||= Connection.instance

        @publisher = DefaultExchangePublisher.new(queue_name: queue_name, connection: connection)
        @publisher.configure_publish_options do |options|
          options.expiration = ping_expiration
        end

        @default_ping_options = PingOptions.new
        @confirm_publish = confirm_publish
      end

      def ping(urls, options_hash = {})
        options = PingOptions.new(options_hash)
        options = @default_ping_options.merge(options)

        options.validate

        Array(urls).each do |url|
          next if cached?(url)
          publish(url, options)
          cache!(url)

          yield url if block_given?
        end
      end

      def default_ping_options
        yield @default_ping_options
      end

      private

      def publish(url, options)
        payload = message(url, options)

        if @confirm_publish
          @publisher.publish_with_confirm(payload)
        else
          @publisher.publish(payload)
        end
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
        def self.cached?(_url)
          false
        end

        def self.cache!(url)
          # Do nothing
        end
      end
    end
  end
end
