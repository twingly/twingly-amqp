require "amqp_queue_context"

describe Twingly::AMQP::Ping do
  include_context "amqp queue"

  let(:provider_name) { "test-provider" }
  let(:source_ip)     { "127.0.0.1" }
  let(:priority)      { 1 }

  let(:urls)         { "http://example.com" }
  let(:ping_options) { {} }


  subject do
    described_class.new(
      provider_name: provider_name,
      queue_name:    queue_name,
      source_ip:     source_ip,
      connection:    amqp_connection,
      priority:      priority,
    )
  end

  describe "#ping" do
    before do
      subject.ping(urls, ping_options)
      sleep 1
    end

    context "with one URL" do
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

    context "with :source_ip as argument" do
      let(:ping_source_ip) { "8.8.8.8" }
      let(:ping_options)   { { source_ip: ping_source_ip } }

      it "should send a ping containing that source ip" do
        _, _, payload = amqp_queue.pop

        actual_payload   = JSON.parse(payload, symbolize_names: true)
        actual_source_ip = actual_payload.fetch(:source_ip)
        expect(actual_source_ip).to eq(ping_source_ip)
      end
    end
  end

  context "without :source_ip to constructor" do
    subject do
      described_class.new(
        provider_name: provider_name,
        queue_name:    queue_name,
        priority:      priority,
      )
    end

    describe ".new" do
      it "should not raise an error" do
        expect{ subject }.not_to raise_error
      end
    end

    describe "#ping" do
      context "without :source_ip as argument" do
        it "should raise an argument error" do
          expect { subject.ping(urls) }.to raise_error(ArgumentError)
        end
      end

      context "with :source_ip as argument" do
        it "should not raise an error" do
          expect { subject.ping(urls, source_ip: "1.2.3.4") }.not_to raise_error
        end
      end
    end
  end
end
