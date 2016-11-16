describe Twingly::AMQP::NullLogger do
  subject { described_class.new }

  it { is_expected.to respond_to(:debug) }
  it { is_expected.to respond_to(:info) }
  it { is_expected.to respond_to(:warn) }
  it { is_expected.to respond_to(:error) }
  it { is_expected.to respond_to(:fatal) }
end
