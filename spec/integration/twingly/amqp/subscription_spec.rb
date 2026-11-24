require "amqp_queue_context"
require "timeout"

describe Twingly::AMQP::Subscription do
  SUBSCRIPTION_TIMEOUT = 5

  around(:each) do |example|
    Timeout.timeout(SUBSCRIPTION_TIMEOUT) do
      example.run
    end
  end

  include_context "amqp queue"

  let(:payload_url)    { "http://www.test.se" }
  let(:payload_json)   { { url: payload_url }.to_json }
  let(:exchange_topic) { "twingly-amqp.exchange.test" }
  let(:routing_key)    { "url.blog" }
  let(:routing_keys)   { [routing_key] }
  let(:exchange) do
    channel = amqp_connection.create_channel
    channel.confirm_select
    channel.topic(exchange_topic, durable: true)
  end

  def wait_for_messages_to_be_consumed
    # Publisher confirms just waits for messages to be persisted to a queue, it doesn't wait for
    # messages to be consumed from the queue, see https://github.com/twingly/twingly-amqp/issues/102
    exchange.wait_for_confirms

    # Sleep for a while to make sure the subscriber has time to consume the messages from the queue
    sleep 0.5
  end

  describe "#initialize" do
    subject(:queue) do
      described_class.new(
        queue_name:     queue_name + ".bounded",
        exchange_topic: exchange_topic,
        routing_keys:   routing_keys,
        max_length:     max_length,
        **queue_options,
      )
    end
    let(:max_length) { nil }
    let(:queue_options) { {} }

    after do
      queue.raw_queue.delete
    end

    specify { expect(queue).to be_a(described_class) }

    context "when using the deprecated routing_key argument" do
      let(:queue_options) { { routing_key: routing_key } }

      it { expect { queue }.not_to raise_error }
    end

    context "when the routing_keys argument isn't an array" do
      let(:routing_keys) { "a-single-routing-key" }

      it { expect { queue }.not_to raise_error }
    end

    context "with max_length set (bounded queue)" do
      let(:max_length) { 10 }

      context "when overpublished" do
        before do
          queue

          (2 * max_length).times do
            exchange.publish(payload_json, routing_key: routing_key)
          end
          wait_for_messages_to_be_consumed
        end

        it "ensures only max_length messages are queued" do
          expect(queue.message_count).to eq(max_length)
        end
      end
    end

    describe "queue_type" do
      subject(:queue_type) { queue.raw_queue.arguments["x-queue-type"] }

      it "creates a queue with the default queue type (quorum)" do
        expect(queue_type).to eq("quorum")
      end

      context "with queue_type set to :quorum" do
        let(:queue_options) { { queue_type: :quorum } }

        it "creates a quorum queue" do
          expect(queue_type).to eq("quorum")
        end
      end

      context "with queue_type set to :classic" do
        let(:queue_options) { { queue_type: :classic } }

        it "creates a queue with the default queue type (classic)" do
          expect(queue_type).to be_nil
        end
      end
    end
  end

  describe "#message_count" do
    subject! do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_keys:   routing_keys,
      )
    end

    context "for an empty queue" do
      specify { expect(subject.message_count).to be_zero }
    end

    context "for a queue with messages" do
      before do
        message_count.times do
          exchange.publish(payload_json, routing_key: routing_key)
        end
        wait_for_messages_to_be_consumed
      end

      let(:message_count) { 3 }

      specify { expect(subject.message_count).to eq(message_count) }
    end
  end

  describe "#raw_queue" do
    subject do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_keys:   routing_keys,
      )
    end

    specify { expect(subject.raw_queue).to be_a(Bunny::Queue) }
  end

  describe "#each_message" do
    subject! do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_keys:   routing_keys,
      )
    end

    context "when message has same routing key" do
      it "should receive the message published on the exchange" do
        exchange.publish(payload_json, routing_key: routing_key)
        wait_for_messages_to_be_consumed

        received_url = nil
        subject.each_message do |message|
          received_url = message.payload[:url]
          subject.cancel!
        end

        expect(received_url).to eq(payload_url)
      end
    end

    context "when subscribing using multiple routing keys" do
      let(:routing_keys_and_payload_urls) do
        {
          "url.blog" => "https://blog.twingly.com/",
          "url.post" => "https://blog.twingly.com/2006/09/05/twingly",
        }
      end

      let(:routing_keys)  { routing_keys_and_payload_urls.keys }
      let(:expected_urls) { routing_keys_and_payload_urls.values }

      it "should receive messages matching any of the routing keys" do
        routing_keys_and_payload_urls.each do |routing_key, url|
          exchange.publish({ url: url }.to_json, routing_key: routing_key)
        end

        wait_for_messages_to_be_consumed

        received_urls = []
        subject.each_message do |message|
          received_urls << message.payload[:url]

          if received_urls.count == routing_keys_and_payload_urls.count
            subject.cancel!
          end
        end

        expect(received_urls).to match_array(expected_urls)
      end
    end

    context "when there are message with other routing keys" do
      let(:another_routing_key) { "url.post" }

      it "should not receive those messages" do
        1.upto(10) do
          exchange.publish("other message", routing_key: another_routing_key)
        end

        exchange.publish(payload_json, routing_key: routing_key)
        wait_for_messages_to_be_consumed

        received_url = nil
        subject.each_message do |message|
          received_url = message.payload[:url]
          subject.cancel!
        end

        expect(received_url).to eq(payload_url)
      end
    end

    context "when a before_handle_message callback has been set" do
      it "should call the callback" do
        exchange.publish(payload_json, routing_key: routing_key)
        wait_for_messages_to_be_consumed

        unparsed_payload = nil
        subject.before_handle_message do |raw_payload|
          unparsed_payload = raw_payload
        end
        subject.each_message { |_| subject.cancel! }

        expect(unparsed_payload).to eq(payload_json)
      end
    end

    context "when an exception is raised" do
      it "should call exception callback" do
        exchange.publish("this is not json", routing_key: routing_key)
        wait_for_messages_to_be_consumed

        on_exception_called = false
        subject.on_exception do |_|
          on_exception_called = true
          subject.cancel!
        end
        subject.each_message { |_| subject.cancel! }

        expect(on_exception_called).to eq(true)
      end

      context "and a logger is configured" do
        let(:logger) { instance_double("Logger") }

        before do
          Twingly::AMQP.configure do |config|
            config.logger = logger
          end
        end

        it "logs the exception" do
          expect(logger).to receive(:error)

          exchange.publish("this is not json", routing_key: routing_key)
          wait_for_messages_to_be_consumed

          subject.on_exception do |_|
            subject.cancel!
          end
          subject.each_message { |_| subject.cancel! }
        end
      end
    end

    context "when a channel error occurs" do
      def simulate_channel_error(channel)
        channel_error_code = 406
        channel_error_message =
          "PRECONDITION_FAILED - delivery acknowledgement on channel #{channel.id} timed out."
        channel.instance_variable_get(:@on_error).call(
          channel,
          AMQ::Protocol::Channel::Close.new(
            channel_error_code,
            channel_error_message,
            0,
            0
          )
        )
      end

      it "should call error callback" do
        expect do |block|
          subject.on_error(&block)
          simulate_channel_error(subject.raw_queue.channel)
        end.to yield_with_args(subject.raw_queue.channel, be_kind_of(AMQ::Protocol::Channel::Close))
      end
    end

    context "when the server closes the connection in the middle of a frame",
            skip: !defined?(Bunny::ExceptionAccumulator) && "Bunny #{Bunny::VERSION} raises reader loop errors asynchronously" do
      let(:connection) { Twingly::AMQP::Session.new(logger: Logger.new(File::NULL)).connection }
      let(:subscription) { described_class.new(queue_name: queue_name, connection: connection) }
      let(:other_subscription) { described_class.new(queue_name: queue_name, connection: connection) }
      let(:publisher) do
        Twingly::AMQP::DefaultExchangePublisher.new(queue_name: queue_name, connection: connection)
      end
      let(:framing_error) { /Frame payload should be 10 long/ }

      before do
        # Opens all channels and declares the queue before anything is stubbed
        subscription
        other_subscription
        publisher

        # Fail the first read after consume-ok, so each_message has reached its loop
        consume_ok_handled = false
        allow(connection).to receive(:handle_frame).and_wrap_original do |original, *args|
          original.call(*args).tap do
            consume_ok_handled = true if args.last.is_a?(AMQ::Protocol::Basic::ConsumeOk)
          end
        end
        allow(connection.transport).to receive(:read_next_frame).and_wrap_original do |original, *args|
          raise Bunny::BadLengthError.new(10, 5) if consume_ok_handled

          original.call(*args)
        end
      end

      after do
        # The reader is dead, so skip the close handshakes and only stop Bunny's threads
        connection.transport.close
        connection.close
      end

      it "raises the error from each_message" do
        expect { Timeout.timeout(3) { subscription.each_message { |_| } } }
          .to raise_error(Bunny::NetworkFailure, framing_error)
      end

      context "after the connection has failed" do
        before do
          Timeout.timeout(3) { subscription.each_message { |_| } }
        rescue Bunny::NetworkFailure
          # Expected, the connection is dead now
        end

        it "raises the error when publishing" do
          expect { publisher.publish(url: payload_url) }
            .to raise_error(Bunny::NetworkFailure, framing_error)
        end

        it "raises the error when subscribing" do
          expect { Timeout.timeout(1) { other_subscription.each_message(blocking: false) { |_| } } }
            .to raise_error(Bunny::NetworkFailure, framing_error)
        end
      end
    end

    context "when the server cancels the consumer" do
      let(:logger) { instance_double("Logger", warn: nil) }

      before do
        Twingly::AMQP.configure do |config|
          config.logger = logger
        end
      end

      after do
        Twingly::AMQP.configure do |config|
          config.logger = Twingly::AMQP::NullLogger.new
        end
      end

      # Deleting the queue makes the server send basic.cancel to its consumers,
      # just like a consumer timeout does on RabbitMQ 4.3+
      def cancel_consumer_on_server
        channel = amqp_connection.create_channel
        channel.queue_delete(queue_name)
        channel.close
      end

      context "when blocking is true" do
        it "stops the subscription" do
          exchange.publish(payload_json, routing_key: routing_key)
          wait_for_messages_to_be_consumed

          subject.each_message do |message|
            message.ack
            cancel_consumer_on_server
          end

          expect(subject.cancel?).to eq(true)
        end
      end

      context "when blocking is false" do
        it "stops the subscription" do
          subject.each_message(blocking: false) { |_| }
          cancel_consumer_on_server
          sleep 0.5

          expect(subject.cancel?).to eq(true)
        end
      end

      it "logs a warning" do
        subject.each_message(blocking: false) { |_| }
        cancel_consumer_on_server
        sleep 0.5

        expect(logger).to have_received(:warn).with(/cancelled by the server/)
      end
    end

    context "without exchange_topic and routing_key" do
      let(:default_exchange) do
        channel = amqp_connection.create_channel
        channel.confirm_select
        channel.default_exchange
      end

      subject! do
        described_class.new(
          queue_name: queue_name,
        )
      end

      it "should subscribe to default exchange" do
        default_exchange.publish(payload_json, routing_key: queue_name)
        wait_for_messages_to_be_consumed

        received_url = nil
        subject.each_message do |message|
          received_url = message.payload[:url]
          subject.cancel!
        end

        expect(received_url).to eq(payload_url)
      end
    end

    context "when blocking is false" do
      let(:message_count) { 2 }

      after { subject.cancel! }

      it "should be non-blocking" do
        exchange.publish(payload_json, routing_key: routing_key)
        wait_for_messages_to_be_consumed

        is_non_blocking = false
        subject.each_message(blocking: false) { |_| }
        is_non_blocking = true

        expect(is_non_blocking).to eq(true)
      end

      it "should receive the messages published on the exchange" do
        received_urls = []
        subject.each_message(blocking: false) do |message|
          received_urls << message.payload[:url]
        end

        message_count.times do
          exchange.publish(payload_json, routing_key: routing_key)
        end

        wait_for_messages_to_be_consumed

        expect(received_urls.count).to eq(message_count)
      end
    end
  end

  describe "#cancel!" do
    subject! do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_key:    routing_key,
      )
    end

    before do
      exchange.publish(payload_json, routing_key: routing_key)
      wait_for_messages_to_be_consumed
    end

    context "when blocking is true" do
      it "cancels the consumer" do
        subject.each_message do |message|
          message.ack
          subject.cancel!
        end

        expect(subject.raw_queue.consumer_count).to be_zero
      end
    end

    context "when blocking is false" do
      it "cancels the consumer" do
        subject.each_message(blocking: false) { |message| message.ack }

        expect { subject.cancel! }.to change { subject.raw_queue.consumer_count }.from(1).to(0)
      end
    end
  end
end
