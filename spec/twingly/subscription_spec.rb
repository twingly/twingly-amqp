require "amqp_queue_context"
require "timeout"

describe Twingly::AMQP::Subscription do
  SUBSCRIPTION_TIMEOUT = 5

  around(:each) do |example|
    Timeout::timeout(SUBSCRIPTION_TIMEOUT) do
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
    channel.topic(exchange_topic, durable: true)
  end

  subject! do
    described_class.new(
      queue_name:     queue_name,
      exchange_topic: exchange_topic,
      routing_key:    routing_key
    )
  end

  describe "#each_message" do
    context "when message has same routing key" do
      it "should receive the message published on the exchange" do
        exchange.publish(payload_json, routing_key: routing_key)
        sleep 1

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
        sleep 1

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
        sleep 1

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
        sleep 1

        on_exception_called = false
        subject.on_exception do |_|
          on_exception_called = true
          subject.cancel!
        end
        subject.each_message { |_| subject.cancel! }

        expect(on_exception_called).to eq(true)
      end
    end

    context "without exchange_topic and routing_key" do
      let(:default_exchange) do
        amqp_connection.create_channel.default_exchange
      end

      subject! do
        described_class.new(
          queue_name: queue_name,
        )
      end

      it "should subscribe to default exchange" do
        default_exchange.publish(payload_json, routing_key: queue_name)
        sleep 1

        received_url = nil
        subject.each_message do |message|
          received_url = message.payload[:url]
          subject.cancel!
        end

        expect(received_url).to eq(payload_url)
      end
    end
  end
end
