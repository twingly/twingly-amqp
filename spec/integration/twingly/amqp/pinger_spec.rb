require "amqp_queue_context"

describe Twingly::AMQP::Pinger do
  include_context "amqp queue"

  subject do
    described_class.new(
      queue_name: queue_name,
      connection: amqp_connection,
    )
  end

  describe "#ping" do
    let(:provider_name) { "test-provider" }
    let(:source_ip)     { "127.0.0.1" }
    let(:priority)      { 1 }

    let(:urls)         { "http://example.com" }
    let(:ping_options) do
      {
        provider_name: provider_name,
        source_ip:     source_ip,
        priority:      priority,
      }
    end

    context "when expiration has been set" do
      let(:ping_expiration) { 2_000 } # ms
      subject do
        described_class.new(
          queue_name:      queue_name,
          connection:      amqp_connection,
          ping_expiration: ping_expiration,
        )
      end

      before do
        subject.ping(urls, ping_options)

        # wait until the ping has been published to target queue
        sleep 1
      end

      it "the ping should be discarded after it expires" do
        expect(amqp_queue.message_count).to eq(1)

        sleep ping_expiration / 1000

        expect(amqp_queue.message_count).to eq(0)
      end
    end

    context "with all required options set" do
      before do
        subject.ping(urls, ping_options)
        sleep 1
      end

      context "with one URL" do
        let(:expected_payload) do
          {
            provider_name:  provider_name,
            priority:       priority,
            source_ip:      source_ip,
            url:            urls,
            automatic_ping: false,
          }
        end

        it "should publish one message to the queue" do
          expect(amqp_queue.message_count).to eq(1)
        end

        it "should publish a valid message" do
          _, _, payload = amqp_queue.pop

          actual_payload = JSON.parse(payload, symbolize_names: true)
          expect(actual_payload).to include(expected_payload)
        end
      end

      context "with an array of URLs" do
        let(:urls) do
          %w(http://example.com http://test.se https://another-one.com)
        end

        it "should send multiple messages" do
          expect(amqp_queue.message_count).to eq(urls.length)
        end
      end
    end

    context "without required options set" do
      let(:ping_options) { {} }

      it "should raise an argument error" do
        expect { subject.ping(urls, ping_options) }
          .to raise_error(ArgumentError)
      end
    end

    context "with default options set" do
      before do
        subject.default_ping_options do |options|
          options.provider_name = provider_name
          options.source_ip     = source_ip
          options.priority      = priority
        end
      end

      it "should not raise an  error" do
        expect { subject.ping(urls) }.not_to raise_error
      end
    end
  end
end
