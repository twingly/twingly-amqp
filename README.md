# Twingly::AMQP

[![Build Status](https://travis-ci.org/twingly/twingly-amqp.svg?branch=master)](https://travis-ci.org/twingly/twingly-amqp)


A gem for subscribing and publishing messages via RabbitMQ.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "twingly-amqp", :git => "git@github.com:twingly/twingly-amqp.git"
```

## Usage

Environment variables:

* `RABBITMQ_N_HOST`
* `AMQP_USERNAME`
* `AMQP_PASSWORD`
* `AMQP_TLS` # Use TLS connection if set

### Customize options

If you don't have the RabbitMQ hosts in your ENV you can set them with `Twingly::AMQP::Connection.options=` before you create an instance of `Subscription` or `Ping`.

```ruby
Twingly::AMQP::Connection.options = {
  hosts: "localhost",
}
```

### Subscribe to a queue

```ruby
subscription = Twingly::AMQP::Subscription.new(
  queue_name:       "crawler-urls",
  exchange_topic:   "url-exchange", # Optional, uses the default exchange if omitted
  routing_key:      "url.blog",     # Optional, uses the default exchange if omitted
  consumer_threads: 4,              # Optional
  prefetch:         20,             # Optional
)

subscription.on_exception { |exception| puts "Oh noes! #{exception.message}" }
subscription.before_handle_message { |raw_message_payload| puts raw_message }

subscription.subscribe do |message| # An instance of Twingly::AMQP::Message
  begin
    response = client.post(payload.fetch(:url))

    case response.code
    when 200 then message.ack     # No error
    when 404 then message.reject  # Permanent error, discard
    when 500 then message.requeue # Transient error, retry
    end
  rescue
    # It's up to the client to handle all exceptions
    message.reject                # Unknown error, discard
  end
end
```

### Ping urls

```ruby
pinger = Twingly::AMQP::Ping.new(
  provider_name: "a-provider-name",
  queue_name:    "provider-ping",
  priority:      1,
  source_ip:     "?.?.?.?", # Optional, can be given to #ping
  url_cache:     url_cache, # Optional, see below
)

urls = [
  "http://blog.twingly.com",
]

pinger.ping(urls) do |pinged_url|
  # Optional block that gets called for each pinged url
end

# Send a ping using another source ip
pinger.ping(urls, source_ip: "1.2.3.4")
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

## Tests

The tests require a local RabbitMQ server to run.

Run tests with

```shell
bundle exec rake
```

## Release workflow

**Note**: Make sure you are logged in as [twingly][twingly-rubygems] at RubyGems.org.

Build and [publish](http://guides.rubygems.org/publishing/) the gem.

    bundle exec rake release

[twingly-rubygems]: https://rubygems.org/profiles/twingly
