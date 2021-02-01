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

          it { is_expected.to be false }
        end
      end

      describe "arguments:" do
        subject { created_queue.arguments }

        context "by default" do
          it { is_expected.to be_empty }
        end

        context "with a hash containing optional queue arguments" do
          let(:arguments_hash) { { "x-some-argument": "some-value" } }

          before { options[:arguments] = arguments_hash }

          it "creates queue with the given arguments" do
            is_expected.to eq(arguments_hash)
          end
        end
      end
    end
  end
end
