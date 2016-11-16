shared_context "amqp queue" do
  let(:queue_name)       { "twingly-amqp.test" }
  let(:bound_queue_name) { "twingly-amqp.test.bound" }
  let(:exchange_name)    { "twingly-amqp.test.exchange" }
  let(:routing_key)      { "routing.test" }

  let(:amqp_connection) do
    Twingly::AMQP::Connection.instance
  end

  let(:amqp_queue) do
    channel = amqp_connection.create_channel
    channel.queue(queue_name, durable: true)
  end

  let(:topic_exchange) do
    amqp_connection.create_channel.topic(exchange_name)
  end

  let(:bound_amqp_queue) do
    channel = amqp_connection.create_channel
    queue = channel.queue(bound_queue_name)
    queue.bind(topic_exchange)
  end

  before do
    amqp_queue
    topic_exchange
    bound_amqp_queue
  end

  after do
    amqp_queue.delete
    bound_amqp_queue.delete
    topic_exchange.delete
  end
end
