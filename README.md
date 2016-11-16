# Twingly::AMQP

[![Build Status](https://travis-ci.org/twingly/twingly-amqp.svg?branch=master)](https://travis-ci.org/twingly/twingly-amqp)


A gem for subscribing and publishing messages via RabbitMQ.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "twingly-amqp"
```

Or install it yourself as:

    $ gem install twingly-amqp

## Usage

Environment variables:

* `RABBITMQ_N_HOST` - Defaults to `localhost`
* `AMQP_USERNAME` - Defaults to `guest`
* `AMQP_PASSWORD` - Defaults to `guest`
* `AMQP_TLS` - Use TLS connection if set

### Customize options

If you don't have the RabbitMQ hosts, user or password in your ENV you can set them via `Twingly::AMQP.configure.connection_options` before you create an instance of `Subscription` or `Pinger`. All options are sent to `Bunny.new`, see the [documentation][ruby-bunny] for all available options.

*Options set via `configure.connection_options` take precedence over the options defined in `ENV`.*

In addition to `connection_options` you may also configure an error logger via `logger`:

```ruby
Twingly::AMQP.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.connection_options = {
    hosts: %w(localhost),
    user: "a-user",
    pass: "1234",
    # ...
  }
end
```

[ruby-bunny]: http://rubybunny.info/articles/connecting.html

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

subscription.each_message do |message| # An instance of Twingly::AMQP::Message
  begin
    response = client.post(message.payload.fetch(:url))

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

### Publish to a queue

```ruby
publisher = Twingly::AMQP::QueuePublisher.new(queue_name: "my_queue")

publisher.configure_publish_options do |options|
  options.expiration = 1000
  options.priority   = 1
end

publisher.publish({ my: "data" })
```

### Ping urls

```ruby
pinger = Twingly::AMQP::Pinger.new(
  queue_name:      "provider-ping",
  ping_expiration: 2_000,     # Optional, ms, discard the ping if it's still on
                              #   the queue after this amount of milliseconds
  url_cache:       url_cache, # Optional, see below
)

# Optional, options can also be given to #ping
pinger.default_ping_options do |options|
  options.provider_name = "TestProvider"
  options.source_ip     = "?.?.?.?"
  options.priority      = 1
end

urls = [
  "http://blog.twingly.com",
]

# Optional, is merged with the default options above
options = {
  provider_name: "a-provider-name",
  source_ip:     "?.?.?.?",
  priority:      1,
}

pinger.ping(urls, options) do |pinged_url|
  # Optional block that gets called for each pinged url
end
```

#### Url cache

`Twingly::AMQP::Pinger.new` can optionally take an url cache which caches the urls and only pings in the urls that isn't already cached. The cache needs to respond to the two following methods:

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

### Connection instance

It's possible to get ahold of the current connection, or create a new if no session has been established yet, which may be useful when needing to do things currently not abstracted by the gem.

```ruby
connection = Twingly::AMQP::Connection.instance
# connection is a Bunny::Session
```

## Tests

The integration tests run by default and require a local RabbitMQ server to run.

Run tests with

```shell
bundle exec rake
```

Run just the unit tests with

```shell
bundle exec rake spec:unit
```

### RuboCop

To run static code analysis:

  bundle exec rubocop

  # optionally on single file(s)
  bundle exec rubocop lib/twingly/amqp/*

## Release workflow

* Bump the version in `lib/twingly/amqp/version.rb` in a commit, no need to push (the release task does that).

* Build and [publish](http://guides.rubygems.org/publishing/) the gem. This will create the proper tag in git, push the commit and tag and upload to RubyGems.

        bundle exec rake release

    * If you are not logged in as [twingly][twingly-rubygems] with ruby gems, the rake task will fail and tell you to set credentials via `gem push`, do that and run the `release` task again. It will be okay.

* Update the changelog with [GitHub Changelog Generator](https://github.com/skywinder/github-changelog-generator/) (`gem install github_changelog_generator` if you don't have it, set `CHANGELOG_GITHUB_TOKEN` to a personal access token to avoid rate limiting by GitHub). This command will update `CHANGELOG.md`, commit and push manually.

        github_changelog_generator -u twingly -p twingly-amqp

[twingly-rubygems]: https://rubygems.org/profiles/twingly
