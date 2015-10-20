require "twingly/amqp/version"

ENV["RUBY_ENV"] ||= "development"

require "twingly/amqp/connection"
require "twingly/amqp/subscription"
require "twingly/amqp/ping"
