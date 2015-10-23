describe Twingly::AMQP::Session do
  describe ".new" do
    let(:hosts) { [ "localhost" ] }
    let(:rabbitmq_host_env_name) { "RABBITMQ_01_HOST" }

    context "without arguments" do
      it "should read them from ENV" do
        expect { described_class.new }.to_not raise_exception
      end
    end

    context "when given hosts array as argument" do
      it "should not read them from ENV" do
        expect(ENV).not_to receive(:[]).with(rabbitmq_host_env_name)

        described_class.new(hosts: hosts)
      end
    end

    context "when AMQP_TLS is set" do
      before { ENV["AMQP_TLS"] = "oh yeah" }
      after  { ENV.delete("AMQP_TLS") }

      it "should enable tls for bunny" do
        expect { described_class.new }.to raise_error(Bunny::TCPConnectionFailedForAllHosts)
      end
    end
  end
end