require_relative "../lib/twingly/amqp/default_exchange_publisher"

queue     = "awesome.queue"
publisher = Twingly::AMQP::DefaultExchangePublisher.new(queue_name: queue)

publisher.configure_publish_options do |options|
  options.expiration = 5000
end

publisher.publish({ my: "data" })
