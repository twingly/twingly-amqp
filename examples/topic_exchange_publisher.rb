require_relative "../lib/twingly/amqp/topic_exchange_publisher"

exchange  = "awesome.exchange"
publisher = Twingly::AMQP::TopicExchangePublisher.new(exchange_name: exchange)

publisher.configure_publish_options do |options|
  options.expiration = 5000
end

publisher.publish(my: "data")
