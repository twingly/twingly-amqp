describe Twingly::AMQP::Message do
  let(:delivery_tag) { 1 }
  let(:delivery_info) do
    double("delivery_info", delivery_tag: delivery_tag)
  end
  let(:metadata)      { "metadata" }
  let(:payload)       { { url: "test.se" } }
  let(:channel)       { double("channel") }
  let(:message_data) do
    {
      delivery_info: delivery_info,
      metadata:      metadata,
      payload:       payload.to_json,
      channel:       channel,
    }
  end

  subject { described_class.new(message_data) }
  it { is_expected.to respond_to(:delivery_info) }
  it { is_expected.to respond_to(:metadata) }
  it { is_expected.to respond_to(:payload) }
  it { is_expected.to respond_to(:ack) }
  it { is_expected.to respond_to(:requeue) }
  it { is_expected.to respond_to(:reject) }

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

  describe "#ack" do
    it "should send ack to the channel" do
      expect(channel).to receive(:ack).with(delivery_tag)

      subject.ack
    end
  end

  describe "#requeue" do
    it "should send reject with requeue to the channel" do
      expect(channel).to receive(:reject).with(delivery_tag, true)

      subject.requeue
    end
  end

  describe "#reject" do
    it "should send reject without requeue to the channel" do
      expect(channel).to receive(:reject).with(delivery_tag, false)

      subject.reject
    end
  end
end
