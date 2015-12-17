describe Twingly::AMQP::Connection do
  subject { described_class }

  it { is_expected.to     respond_to(:options=) }
  it { is_expected.to     respond_to(:instance) }
  it { is_expected.not_to respond_to(:new) }
end
