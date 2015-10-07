# Twingly::Amqp

A gem for sending pings via RabbitMQ.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twingly-amqp'
```

## Usage

```
  options = { } # See twingly
  pinger = Twingly::AMQP::Ping.new(options)

  urls = [
    "http://blog.twingly.com",
  ]

  pinger.ping(urls)
```
