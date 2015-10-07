# Twingly::AMQP

[![Build Status](https://magnum.travis-ci.com/twingly/twingly-amqp.svg?token=qpeLsZ1ShGKXQVMsum51)](https://magnum.travis-ci.com/twingly/twingly-amqp)

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
  url_cache:     url_cache, # Optional, see below
)

urls = [
  "http://blog.twingly.com",
]

pinger.ping(urls)
```

### Url cache

`Twingly::AMQP::Ping.new` can optionally take an url cache which caches the urls and only pings in the urls that isn't already cached. The cache needs to respond to the two following methods:

```ruby
class UrlCache
  def cached?(url)
    # return true/false
  end

  def cache!(url)
    # cache url
  end
end
```
