require "twingly/amqp/connection"
require "json"

module Twingly
  module AMQP
    class Ping
      def initialize(provider_name:, queue_name:, source_ip:, priority:, connection:, logger: nil)
        @logger = logger

        @provider_name = provider_name
        @queue_name    = queue_name
        @source_ip     = source_ip
        @priority      = priority

        @channel = connection.create_channel
      end

      def ping(urls)
        urls.each do |url|
          publish(url)
          log("Pinged #{url}")
        end
      end

      private

      def log(msg)
        @logger.info(msg) if @logger
      end

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
    end
  end
end
