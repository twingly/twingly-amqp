require "amqp_queue_context"
require "publisher_examples"

describe Twingly::AMQP::TopicExchangePublisher do
  include_context "amqp queue"

  let(:amqp_queue) { topic_exchange_queue }

  subject do
    described_class.new(
      exchange_name: topic_exchange_name,
      connection: amqp_connection,
    )
  end

  include_examples "publisher"

  describe "#publish" do
    context "with routing_key set" do
      let(:routing_key) { "routing.test" }

      before do
        subject.configure_publish_options do |options|
          options.routing_key = routing_key
        end

        amqp_queue.bind(topic_exchange, routing_key: routing_key)
        subject.publish_with_confirm(payload)
      end

      it "does route the message" do
        _, _, json_payload = amqp_queue.pop

        actual_payload = JSON.parse(json_payload, symbolize_names: true)
        expect(actual_payload).to eq(payload)
      end
    end

    context "with opts set" do
      subject do
        exchange_options = {
          durable: true,
        }

        described_class.new(
          exchange_name: topic_exchange_name,
          connection: amqp_connection,
          opts: exchange_options,
        )
      end

      it "does honor opts" do
        # queue is already created with durable set to false
        expect { subject.publish_with_confirm(payload) }
          .to raise_error(Bunny::PreconditionFailed)
      end
    end

    context "with routing_key given to #publish" do
      let(:routing_key) { "routing.test.used" }

      before do
        subject.configure_publish_options do |options|
          options.routing_key = "routing.test.not_used"
        end

        amqp_queue.bind(topic_exchange, routing_key: routing_key)
        subject.publish_with_confirm(payload, routing_key: routing_key)
      end

      it "overrides the previously set routing_key" do
        _, _, json_payload = amqp_queue.pop

        actual_payload = JSON.parse(json_payload, symbolize_names: true)
        expect(actual_payload).to eq(payload)
      end
    end
  end

  describe "#configure_publish_options" do
    it "yields with OpenStruct object" do
      expect { |block| subject.configure_publish_options(&block) }
        .to yield_with_args(OpenStruct)
    end

    let(:default_content_type) { "application/json" }
    let(:default_persistent)   { true }
    it "has default values" do
      subject.configure_publish_options do |options|
        expect(options.content_type).to eq(default_content_type)
        expect(options.persistent).to eq(default_persistent)
      end
    end

    it "accepts any value" do
      subject.configure_publish_options do |options|
        expect { options.anything = "something" }.to_not raise_error
      end
    end
  end
end
