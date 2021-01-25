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
        delay_queue_name: delay_queue_name,
        target_routing_key: target_routing_key,
        target_exchange_name: target_exchange_name,
        delay_ms: delay_ms,
        connection: amqp_connection,
      )
    end

    let(:delay_queue_name) { "#{queue_name}.delayed" }
    let(:delay_ms) { 0 }

    let(:target_routing_key) { "" }
    let(:target_exchange_name) { "" }

    after do
      amqp_connection.with_channel do |channel|
        channel.queue_delete(delay_queue_name)
      end
    end

    shared_examples "publishing with delay" do
      describe "#publish" do
        let(:delay_ms)      { 100 }
        let(:delay_seconds) { delay_ms.to_f / 1000 }
        let(:payload)       { { hello: "world" } }

        subject { delay_queue_publisher.publish_with_confirm(payload) }

        it "creates a queue for delayed messages" do
          subject

          expect(amqp_connection.queue_exists?(delay_queue_name)).to eq(true)
        end

        it "publishes message to target queue after delay has passed" do
          subject

          expect { sleep delay_seconds * 2 }
            .to change { amqp_queue.message_count }.from(0).to(1)
        end
      end
    end

    context "when target_exchange_name is set" do
      let(:amqp_queue)           { topic_exchange_queue }
      let(:target_exchange_name) { topic_exchange_name }

      it { is_expected.to be_a(described_class) }

      include_examples "publishing with delay"
    end

    context "when target_routing_key is set" do
      let(:amqp_queue)         { default_exchange_queue }
      let(:target_routing_key) { queue_name }

      it { is_expected.to be_a(described_class) }

      include_examples "publishing with delay"
    end

    context "when target_exchange_name or target_routing_key isn't set" do
      it "raises an error" do
        expect { subject }
          .to raise_error(ArgumentError,
                          /target_exchange_name or target_routing_key must be set/)
      end
    end
  end
end
