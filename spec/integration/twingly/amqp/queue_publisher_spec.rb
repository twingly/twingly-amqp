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
    [{ some: "data" }, [[:some, "data"]]].each do |payload|
      context "when given a hash-like payload '#{payload}'" do
        before do
          subject.publish_with_confirm(payload)
        end

        let(:expected_payload) { { some: "data" } }

        it "does publish the message" do
          _, _, json_payload = amqp_queue.pop

          actual_payload = JSON.parse(json_payload, symbolize_names: true)
          expect(actual_payload).to eq(expected_payload)
        end
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
        subject.configure_publish_options do |options|
          options.app_id = app_id
        end

        subject.publish_with_confirm(payload)
      end

      it "does honor the customization" do
        _, metadata, _ = amqp_queue.pop

        expect(metadata.to_hash).to include(app_id: app_id)
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
