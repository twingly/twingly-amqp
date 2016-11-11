# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "twingly/amqp/version"

Gem::Specification.new do |spec|
  spec.name          = "twingly-amqp"
  spec.version       = Twingly::Amqp::VERSION
  spec.authors       = ["Twingly AB"]
  spec.email         = ["support@twingly.com"]

  spec.summary       = "Ruby library for talking to RabbitMQ"
  spec.description   = "Publish and subscribe to messages via RabbitMQ"
  spec.homepage      = "https://github.com/twingly/twingly-amqp"

  spec.files         = Dir.glob("{lib}/**/*") + %w(README.md)
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny", "~> 2.2"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rubocop", "~> 0"
end
