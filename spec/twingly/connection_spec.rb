describe Twingly::AMQP::Connection do
  describe ".new" do
    let(:host) { "localhost" }
    let(:rabbitmq_host_env_name) { "RABBITMQ_01_HOST" }

    context "without arguments" do
      it "should read them from ENV" do
        # TODO test doesnt really check that they are read from ENV
        expect { described_class.new }.to_not raise_exception
      end
    end

    context "when given hosts array as argument" do
      it "should not read them from ENV" do
        expect(ENV).not_to receive(:[]).with(rabbitmq_host_env_name)

        described_class.new(hosts: [ host ])
      end
    end
  end
end
