describe Twingly::AMQP::Utilities do
  let(:queue_name)      { "twingly-amqp.utilities.test.queue" }
  let(:amqp_connection) { Twingly::AMQP::Connection.instance }

  subject do
    described_class.create_queue(queue_name, connection: amqp_connection)
  end

  after do
    amqp_connection.with_channel do |channel|
      channel.queue_delete(queue_name)
    end
  end

  it "creates a queue" do
    expect{ subject }
      .to change { amqp_connection.queue_exists?(queue_name) }
      .from(false)
      .to(true)
  end
end
