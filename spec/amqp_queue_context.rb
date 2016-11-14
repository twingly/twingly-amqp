shared_context "amqp queue" do
  let(:queue_name) { "twingly-amqp.test" }

  let(:amqp_connection) do
    Twingly::AMQP::Connection.instance
  end

  let(:amqp_queue) do
    channel = amqp_connection.create_channel
    channel.queue(queue_name, durable: true)
  end

  before do
    amqp_queue
  end

  after do
    amqp_queue.delete
  end
end
