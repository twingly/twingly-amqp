require "amqp_queue_context"
require "publisher_examples"

describe Twingly::AMQP::DefaultExchangePublisher do
  include_context "amqp queue"
  let(:amqp_queue) { default_exchange_queue }

  subject do
    described_class.new(
      queue_name: queue_name,
      connection: amqp_connection,
    )
  end

  include_examples "publisher"
end
