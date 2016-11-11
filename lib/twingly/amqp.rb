require "twingly/amqp/version"
require "twingly/amqp/session"
require "twingly/amqp/connection"
require "twingly/amqp/subscription"
require "twingly/amqp/ping_options"
require "twingly/amqp/pinger"
require "twingly/amqp/null_logger"

require "ostruct"

module Twingly
  module AMQP
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= OpenStruct.new(logger: NullLogger.new)
    end

    def self.configure
      yield configuration
    end
  end
end
