$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'twingly/amqp'

ENV["RUBY_ENV"] = "test"
ENV["AMQP_USERNAME"]    ||= "guest"
ENV["AMQP_PASSWORD"]    ||= "guest"
ENV["RABBITMQ_01_HOST"] ||= "localhost"
