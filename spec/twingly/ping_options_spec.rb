describe Twingly::AMQP::PingOptions do
  it { is_expected.to respond_to(:provider_name) }
  it { is_expected.to respond_to(:source_ip) }
  it { is_expected.to respond_to(:priority) }

  it { is_expected.to respond_to(:to_h) }

  let(:provider_name) { "TestProvider" }
  let(:source_ip)     { "1.2.3.4" }
  let(:priority)      { 1 }

  subject(:subject_with_all_options) do
    described_class.new do |options|
      options.provider_name = provider_name
      options.source_ip     = source_ip
      options.priority      = priority
    end
  end

  describe ".new" do
    context "when given a block" do
      it "should yield self" do
        yielded_options = nil
        options = described_class.new do |o|
          yielded_options = o
        end

        expect(yielded_options).to equal(options)
      end
    end
  end

  describe "#to_h" do
    let(:expected) do
      {
        automatic_ping: false,
        provider_name:  provider_name,
        source_ip:      source_ip,
        priority:       priority,
      }
    end

    subject do
      subject_with_all_options.to_h
    end

    context "when all options are set" do
      it "should return a hash containing correct options" do
        expect(subject).to eq(expected)
      end
    end
  end

  describe "#validate" do
    context "when all options are set" do
      it "should not raise exception" do
        expect { subject_with_all_options.validate }.not_to raise_error
      end
    end

    context "when provider_name isn't set" do
      subject do
        described_class.new do |options|
          options.source_ip     = source_ip
          options.priority      = priority
        end
      end

      it "should raise an exception" do
        expect { subject.validate }.to raise_error(ArgumentError, /provider_name/)
      end
    end

    context "when source_ip isn't set" do
      subject do
        described_class.new do |options|
          options.provider_name = provider_name
          options.priority      = priority
        end
      end

      it "should raise an exception" do
        expect { subject.validate }.to raise_error(ArgumentError, /source_ip/)
      end
    end

    context "when priority isn't set" do
      subject do
        described_class.new do |options|
          options.provider_name = provider_name
          options.source_ip     = source_ip
        end
      end

      it "should raise an exception" do
        expect { subject.validate }.to raise_error(ArgumentError, /priority/)
      end
    end
  end
end
