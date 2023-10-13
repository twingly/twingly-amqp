describe Twingly::AMQP::Utilities do
  describe ".create_queue" do
    let(:queue_name)      { "twingly-amqp.utilities.test.queue" }
    let(:amqp_connection) { Twingly::AMQP::Connection.instance }

    subject do
      described_class.create_queue(queue_name, connection: amqp_connection)
    end

    after do
      amqp_connection.with_channel do |channel|
        channel.queue_delete(queue_name)
      end
    end

    it "creates the queue" do
      expect{ subject }
        .to change { amqp_connection.queue_exists?(queue_name) }
        .from(false)
        .to(true)
    end

    it { is_expected.to be_a(Bunny::Queue) }

    describe "queue options" do
      subject(:created_queue) do
        described_class.create_queue(queue_name, connection: amqp_connection, **options)
      end

      let(:options) { {} }

      describe "durable:" do
        subject { created_queue.durable? }

        context "by default" do
          it { is_expected.to be true }
        end

        context "with durable: false" do
          before { options[:durable] = false }

          it { expect { created_queue }.to raise_error(ArgumentError, "durable: false is not supported by quorum queues") }

          context "when queue_type is :classic" do
            before { options[:queue_type] = :classic }

            it { is_expected.to be false }
          end
        end
      end

      describe "arguments:" do
        subject { created_queue.arguments }

        let(:default_queue_arguments) { { "x-queue-type" => "quorum" } }

        context "by default" do
          it { is_expected.to eq(default_queue_arguments) }
        end

        context "with a hash containing optional queue arguments" do
          let(:arguments_hash) { { "x-some-argument": "some-value" } }

          before { options[:arguments] = arguments_hash }

          it "creates queue with the given arguments" do
            is_expected.to eq(default_queue_arguments.merge(arguments_hash))
          end
        end
      end

      describe "queue_type:" do
        subject(:queue_type) { created_queue.arguments["x-queue-type"] }

        context "by default" do
          it { is_expected.to eq("quorum") }
        end

        context "with queue_type: :quorum" do
          before { options[:queue_type] = :quorum }

          it { is_expected.to eq("quorum") }
        end

        context "with queue_type: :classic" do
          before { options[:queue_type] = :classic }

          it { is_expected.to be_nil }
        end

        context "with queue_type: :not_supported" do
          before { options[:queue_type] = :not_supported }

          it { expect { queue_type }.to raise_error(ArgumentError, "Unknown queue type 'not_supported'") }
        end
      end
    end
  end
end
