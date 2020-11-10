$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "twingly/amqp"

ENV["AMQP_USERNAME"]    ||= "guest"
ENV["AMQP_PASSWORD"]    ||= "guest"
ENV["RABBITMQ_01_HOST"] ||= "localhost"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.warnings = true
end
