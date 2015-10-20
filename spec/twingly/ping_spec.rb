require "amqp_queue_context"

describe Twingly::AMQP::Ping do
  include_context "amqp queue"

  let(:provider_name) { "test-provider" }
  let(:source_ip)     { "127.0.0.1" }
  let(:priority)      { 1 }

  subject do
    described_class.new(
      provider_name: provider_name,
      queue_name:    queue_name,
      source_ip:     source_ip,
      connection:    amqp_connection,
      priority:      priority,
    )
  end

  before do
    subject.ping(urls)
    sleep 1
  end

  describe "#ping" do
    context "with one URL" do
      let(:urls) { "http://example.com" }

      it "should publish one message to the queue" do
        expect(amqp_queue.message_count).to eq(1)
      end

      it "should publish a valid message" do
        expected_payload = {
          provider_name:  provider_name,
          priority:       priority,
          source_ip:      source_ip,
          url:            urls,
          automatic_ping: false,
        }

        _, _, payload = amqp_queue.pop

        actual_payload = JSON.parse(payload, symbolize_names: true)
        expect(actual_payload).to include(expected_payload)
      end
    end

    context "with an array of URLs" do
      let(:urls) { %w(http://example.com http://test.se https://another-one.com) }

      it "should send multiple pings" do
        expect(amqp_queue.message_count).to eq(urls.length)
      end
    end
  end
end
