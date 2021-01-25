require "twingly/amqp/version"
require "twingly/amqp/session"
require "twingly/amqp/connection"
require "twingly/amqp/utilities"
require "twingly/amqp/subscription"
require "twingly/amqp/ping_options"
require "twingly/amqp/pinger"
require "twingly/amqp/publisher"
require "twingly/amqp/default_exchange_publisher"
require "twingly/amqp/topic_exchange_publisher"
require "twingly/amqp/null_logger"
require "twingly/amqp/message"

require "bunny"
require "json"
require "ostruct"

module Twingly
  module AMQP
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||=
        OpenStruct.new(
          logger: NullLogger.new,
          connection_options: {},
        )
    end

    def self.configure
      yield configuration
    end
  end
end
