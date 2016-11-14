describe Twingly::AMQP::Session do
  describe ".new" do
    context "without arguments" do
      let(:amqp_user_from_env) { ENV.fetch("AMQP_USERNAME") }
      let(:amqp_pass_from_env) { ENV.fetch("AMQP_PASSWORD") }
      let(:amqp_host_from_env) { ENV.fetch("RABBITMQ_01_HOST") }
      let(:amqp_options_from_env) do
        {
          user:  amqp_user_from_env,
          pass:  amqp_pass_from_env,
          hosts: [amqp_host_from_env],
        }
      end

      it "should read them from ENV" do
        expect(ENV).to receive(:fetch).at_least(:once).and_call_original

        expect(Bunny)
          .to receive(:new)
          .with(hash_including(amqp_options_from_env))
          .and_call_original

        described_class.new
      end
    end

    context "with arguments" do
      let(:hosts) { ["localhost"] }

      context "with hosts array" do
        let(:rabbitmq_host_env_name) { "RABBITMQ_01_HOST" }

        it "should not read them from ENV" do
          expect(ENV).not_to receive(:[]).with(rabbitmq_host_env_name)

          described_class.new(hosts: hosts)
        end
      end

      context "with multiple options" do
        let(:options) do
          {
            user: "guest",
            pass: "guest",
            hosts: hosts,
            tls: false,
            some_other_option: true,
          }
        end

        it "should pass them all to bunny" do
          expect(Bunny)
            .to receive(:new)
            .with(hash_including(options))
            .and_call_original

          described_class.new(options)
        end
      end

      context "when AMQP_TLS is set" do
        before { ENV["AMQP_TLS"] = "oh yeah" }
        after  { ENV.delete("AMQP_TLS") }

        it "should enable tls for bunny" do
          # since we do not have tls setup when running the tests
          # this will fail with the specified error
          expect { described_class.new }
            .to raise_error(Bunny::TCPConnectionFailedForAllHosts)
        end
      end
    end
  end
end
