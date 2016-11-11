require "amqp_queue_context"

describe Twingly::AMQP::QueuePublisher do
  include_context "amqp queue"

  let(:payload) { { some: "data" } }

  subject do
    described_class.new(
      queue_name: queue_name,
      connection: amqp_connection,
    )
  end

  describe "#publish" do
    context "when given a hash payload" do
      before do
        subject.publish(payload)
        sleep 1
      end

      it "does publish the message" do
        _, _, json_payload = amqp_queue.pop

        actual_payload = JSON.parse(json_payload, symbolize_names: true)
        expect(actual_payload).to eq(payload)
      end
    end

    context "when given a non-hash payload" do
      let(:payload) { "not a hash" }

      it "raises an ArgumentError" do
        expect { subject.publish(payload) }.to raise_error(ArgumentError)
      end
    end

    context "when customizing publish options" do
      let(:app_id) { "test-app" }

      before do
        subject.publish_options do |options|
          options.app_id = app_id
        end

        subject.publish(payload)
        sleep 1
      end

      it "does honor the customization" do
        _, metadata, _ = amqp_queue.pop

        expect(metadata.to_hash).to include(app_id: app_id)
      end
    end
  end
end
