shared_context "amqp queue" do
  let(:queue_name)          { "twingly-amqp.test.queue" }
  let(:topic_queue_name)    { "twingly-amqp.test.queue.topic" }
  let(:topic_exchange_name) { "twingly-amqp.test.exchange.topic" }

  let(:amqp_connection) do
    Twingly::AMQP::Connection.instance
  end

  let(:default_exchange_queue) do
    channel = amqp_connection.create_channel
    channel.queue(queue_name, durable: true)
  end

  let(:topic_exchange) do
    amqp_connection.create_channel.topic(topic_exchange_name)
  end

  let(:topic_exchange_queue) do
    channel = amqp_connection.create_channel
    queue   = channel.queue(topic_queue_name)

    queue.bind(topic_exchange)
  end

  before do
    default_exchange_queue

    topic_exchange
    topic_exchange_queue
  end

  after do
    default_exchange_queue.delete

    topic_exchange_queue.delete
    topic_exchange.delete
  end
end
