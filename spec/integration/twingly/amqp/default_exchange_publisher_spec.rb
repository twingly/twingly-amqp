require "amqp_queue_context"
require "publisher_examples"

describe Twingly::AMQP::DefaultExchangePublisher do
  include_context "amqp queue"

  let(:amqp_queue) { default_exchange_queue }

  subject do
    described_class.new(
      queue_name: queue_name,
      connection: amqp_connection,
    )
  end

  include_examples "publisher"

  describe "#delayed" do
    subject(:delay_queue_publisher) do
      described_class.delayed(
        delay_queue_name:  delay_queue_name,
        target_queue_name: target_queue_name,
        delay_ms:          delay_ms,
        connection:        amqp_connection,
      )
    end

    let(:delay_queue_name)  { "#{queue_name}.delayed" }
    let(:target_queue_name) { queue_name }
    let(:delay_ms)          { 0 }

    after do
      amqp_connection.with_channel do |channel|
        channel.queue_delete(delay_queue_name)
      end
    end

    it { is_expected.to be_a(described_class) }

    context "with delay_queue_type set to :quorum" do
      subject(:delay_queue_publisher) do
        described_class.delayed(
          delay_queue_name:  delay_queue_name,
          target_queue_name: target_queue_name,
          delay_ms:          delay_ms,
          delay_queue_type:  :quorum,
          connection:        amqp_connection,
        )
      end

      before { allow(Twingly::AMQP::Utilities).to receive(:create_queue) }

      it "uses 'Utilities.create_queue' to create a quorum queue" do
        delay_queue_publisher

        expect(Twingly::AMQP::Utilities)
          .to have_received(:create_queue)
          .with(delay_queue_name, hash_including(queue_type: :quorum))
      end
    end

    describe "#publish" do
      let(:delay_ms)      { 100 }
      let(:delay_seconds) { delay_ms.to_f / 1000 }
      let(:payload)       { { hello: "world" } }

      subject { delay_queue_publisher.publish_with_confirm(payload) }

      it "creates a queue for delayed messages" do
        expect{ subject }
          .to change { amqp_connection.queue_exists?(delay_queue_name) }
          .from(false)
          .to(true)
      end

      it "publishes message to target queue after delay has passed" do
        subject

        expect { sleep delay_seconds * 2 }
          .to change { amqp_queue.message_count }.from(0).to(1)
      end
    end
  end
end
