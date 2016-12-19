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
  let(:exchange) do
    channel = amqp_connection.create_channel
    channel.confirm_select
    channel.topic(exchange_topic, durable: true)
  end

  describe "#initialize" do
    subject! do
      described_class.new(
        queue_name:     queue_name + ".bounded",
        exchange_topic: exchange_topic,
        routing_key:    routing_key,
        max_length:     max_length,
      )
    end
    let(:max_length) { nil }

    after do
      subject.raw_queue.delete
    end

    specify { expect(subject).to be_a(described_class) }

    context "with max_length set (bounded queue)" do
      let(:max_length) { 10 }

      context "when overpublished" do
        before do
          (2 * max_length).times do
            exchange.publish(payload_json, routing_key: routing_key)
          end
          exchange.wait_for_confirms
        end

        it "ensures only max_length messages are queued" do
          expect(subject.message_count).to eq(max_length)
        end
      end
    end
  end

  describe "#message_count" do
    subject! do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_key:    routing_key,
      )
    end

    context "for an empty queue" do
      specify { expect(subject.message_count).to eq(0) }
    end

    context "for a queue with messages" do
      before do
        message_count.times do
          exchange.publish(payload_json, routing_key: routing_key)
        end
        exchange.wait_for_confirms
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
        routing_key:    routing_key,
      )
    end

    specify { expect(subject.raw_queue).to be_a(Bunny::Queue) }
  end

  describe "#each_message" do
    subject! do
      described_class.new(
        queue_name:     queue_name,
        exchange_topic: exchange_topic,
        routing_key:    routing_key,
      )
    end

    context "when message has same routing key" do
      it "should receive the message published on the exchange" do
        exchange.publish(payload_json, routing_key: routing_key)
        exchange.wait_for_confirms

        received_url = nil
        subject.each_message do |message|
          received_url = message.payload[:url]
          subject.cancel!
        end

        expect(received_url).to eq(payload_url)
      end
    end

    context "when there are message with other routing keys" do
      let(:another_routing_key) { "url.post" }

      it "should not receive those messages" do
        1.upto(10) do
          exchange.publish("other message", routing_key: another_routing_key)
        end

        exchange.publish(payload_json, routing_key: routing_key)
        exchange.wait_for_confirms

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
        exchange.wait_for_confirms

        unparsed_payload = nil
        subject.before_handle_message do |raw_payload|
          unparsed_payload = raw_payload
        end
        subject.each_message { |_| subject.cancel! }

        expect(unparsed_payload).to eq(payload_json)
      end
    end

    context "when an error is raised" do
      it "should call error callback" do
        exchange.publish("this is not json", routing_key: routing_key)
        exchange.wait_for_confirms

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

        it "logs the error" do
          expect(logger).to receive(:error)

          exchange.publish("this is not json", routing_key: routing_key)
          exchange.wait_for_confirms

          subject.on_exception do |_|
            subject.cancel!
          end
          subject.each_message { |_| subject.cancel! }
        end
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
        exchange.wait_for_confirms

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
        exchange.wait_for_confirms

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

        exchange.wait_for_confirms

        expect(received_urls.count).to eq(message_count)
      end
    end
  end
end
