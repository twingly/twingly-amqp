require_relative "../lib/twingly/amqp/subscription"
require_relative "../lib/twingly/amqp/default_exchange_publisher"

queue_name = "awesome-queue"

subscription = Twingly::AMQP::Subscription.new(
  queue_name: queue_name,
)

subscription.each_message do |message|
  begin
    puts message.payload
  ensure
    message.ack
  end
end
