describe Twingly::AMQP::Message do
  let(:delivery_info) { "delivery_info" }
  let(:metadata)      { "metadata" }
  let(:payload)       { { url: "test.se" } }
  let(:message_data) do
    {
      delivery_info: delivery_info,
      metadata:      metadata,
      payload:       payload.to_json,
    }
  end

  subject { described_class.new(message_data) }
  it { is_expected.to respond_to(:delivery_info) }
  it { is_expected.to respond_to(:metadata) }
  it { is_expected.to respond_to(:payload) }

  describe "#delivery_info" do
    it "should return the delivery info" do
      expect(subject.delivery_info).to eq(delivery_info)
    end
  end

  describe "#metadata" do
    it "should return metadata" do
      expect(subject.metadata).to eq(metadata)
    end
  end

  describe "#payload" do
    it "should return payload as parsed json" do
      expect(subject.payload).to eq(payload)
    end
  end

  describe "#ack?" do
    context "by default" do
      it "should be true" do
        expect(subject.ack?).to eq(true)
      end
    end

    context "when another status is set" do
      before { subject.requeue! }

      it "should be false" do
        expect(subject.ack?).to eq(false)
      end
    end
  end

  describe "#requeue?" do
    context "by default" do
      it "should be false" do
        expect(subject.requeue?).to eq(false)
      end
    end

    context "when it is set" do
      before { subject.requeue! }

      it "should be true" do
        expect(subject.requeue?).to eq(true)
      end
    end
  end

  describe "#discard?" do
    context "by default" do
      it "should be false" do
        expect(subject.discard?).to eq(false)
      end
    end

    context "when it is set" do
      before { subject.discard! }

      it "should be true" do
        expect(subject.discard?).to eq(true)
      end
    end
  end
end
