describe Twingly::AMQP::Connection do
  subject { described_class }

  describe ".instance" do
    context "when called multiple times" do
      it "should return the same instance each time" do
        first_connection  = described_class.instance
        second_connection = described_class.instance

        expect(first_connection).to equal(second_connection)
      end
    end
  end

  describe ".options=" do
    let(:options) { { hosts: %w[host1 host2] } }

    around do |example|
      old_config = Twingly::AMQP.configuration.connection_options
      example.run
      Twingly::AMQP.configuration.connection_options = old_config
    end

    it "updates the configuration" do
      described_class.options = options

      expect(Twingly::AMQP.configuration.connection_options).to eq(options)
    end
  end
end
