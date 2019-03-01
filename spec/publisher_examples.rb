require "ostruct"

shared_examples "publisher" do
  let(:payload) { { some: "data" } }

  describe "#publish" do
    let(:json_payload) do
      _, _, json_payload = amqp_queue.pop

      json_payload
    end

    let(:actual_payload) { JSON.parse(json_payload, symbolize_names: true) }

    context "when given a valid payload" do
      before do
        subject.publish_with_confirm(payload)
      end

      [
        { some: "data" },
        OpenStruct.new(some: "data"),
        nil,
      ].each do |payload_object|
        context "when given a hash-like payload '#{payload_object.inspect}'" do
          let(:payload) { payload_object }
          let(:expected_payload) { payload_object.to_h }

          it "does publish the message" do
            expect(actual_payload).to eq(expected_payload)
          end
        end
      end

      context "when given an array payload" do
        let(:payload) { ["some", "data", 123] }

        it "does publish the message" do
          expect(actual_payload).to eq(payload)
        end
      end
    end

    context "when given an incompatible payload" do
      let(:payload) { "not a valid payload" }

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
