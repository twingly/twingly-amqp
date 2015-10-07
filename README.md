# Twingly::Amqp

A gem for sending pings via RabbitMQ.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "twingly-amqp", :git => "git@github.com:twingly/twingly-amqp.git"
```

## Usage

```ruby
amqp_connection = Twingly::AMQP::Connection(
  hosts: # Optional, uses ENV[/RABBITMQ_\d+_HOST/] by default
)

pinger = Twingly::AMQP::Ping.new(
  provider_name: "a-provider-name",
  queue_name:    "provider-ping",
  source_ip:     "?.?.?.?",
  priority:      1,
  connection:    amqp_connection, # Optional, creates new AMQP::Connection otherwise 
  logger:        logger, # Optional
)

urls = [
  "http://blog.twingly.com",
]

pinger.ping(urls)
```
