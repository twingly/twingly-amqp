require "amqp_queue_context"
require "publisher_examples"

describe Twingly::AMQP::DelayedDefaultExchangePublisher do
  include_context "amqp queue"

  let(:amqp_queue) { default_exchange_queue }
  let(:delay_queue_name) { "#{queue_name}.delayed" }
  let(:delay_ms) { 0 }

  subject(:delay_queue_publisher) do
    described_class.new(
      target_queue_name: queue_name,
      delay_ms: delay_ms,
      connection: amqp_connection,
    )
  end

  after do
    amqp_connection.with_channel do |channel|
      channel.queue_delete(delay_queue_name)
    end
  end

  include_examples "publisher"

  it "creates a queue for delayed messages" do
    subject

    expect(amqp_connection.queue_exists?(delay_queue_name)).to eq(true)
  end

  describe "#publish" do
    let(:delay_ms)      { 100 }
    let(:delay_seconds) { delay_ms.to_f / 1000 }
    let(:payload)       { { hello: "world" } }

    subject { delay_queue_publisher.publish_with_confirm(payload) }

    it "publishes message to target queue after delay has passed" do
      subject

      expect { sleep delay_seconds * 2 }
        .to change { amqp_queue.message_count }.from(0).to(1)
    end
  end
end
