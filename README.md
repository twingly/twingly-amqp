# Twingly::AMQP

[![Build Status](https://travis-ci.org/twingly/twingly-amqp.svg?branch=master)](https://travis-ci.org/twingly/twingly-amqp)


A gem for subscribing and publishing messages via RabbitMQ.

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
```

### Subscribe to a queue

```ruby
subscription = Twingly::AMQP::Subscription.new(
  queue_name:       "queue-to-subscribe-to",
  exchange_topic:   "exchange-name-to-connect-queue-to",
  routing_key:      "blog.url.#",
  consumer_threads: 4, # Optional
  prefetch:         20, # Optional
  connection:       amqp_connection, # Optional, creates new AMQP::Connection if not set
)

subscription.subscribe do |payload|
  # The payload is parsed JSON
  puts payload[:some_key]
end
```

### Ping urls

```ruby
pinger = Twingly::AMQP::Ping.new(
  provider_name: "a-provider-name",
  queue_name:    "provider-ping",
  source_ip:     "?.?.?.?",
  priority:      1,
  connection:    amqp_connection, # Optional, creates new AMQP::Connection if not set
  url_cache:     url_cache, # Optional, see below
)

urls = [
  "http://blog.twingly.com",
]

pinger.ping(urls) do |pinged_url|
  # Optional block that gets called for each pinged url
end
```

#### Url cache

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
