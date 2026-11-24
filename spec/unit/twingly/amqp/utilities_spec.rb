describe Twingly::AMQP::Utilities do
  describe ".raise_if_connection_failed" do
    subject { described_class.raise_if_connection_failed(connection) }

    let(:error)      { Bunny::NetworkFailure.new("reader loop stopped", nil) }
    let(:connection) { double("connection", session_error_handler: handler) }

    context "with Bunny's exception accumulator",
            skip: !defined?(Bunny::ExceptionAccumulator) && "Bunny #{Bunny::VERSION} has no exception accumulator" do
      let(:handler) { Bunny::ExceptionAccumulator.new }

      context "when it has stored errors" do
        let(:framing_error) { Bunny::BadLengthError.new(10, 5) }
        let(:error)         { Bunny::NetworkFailure.new("reader loop stopped", framing_error) }

        before { handler.raise(error) }

        def raised_error
          described_class.raise_if_connection_failed(connection)
        rescue Bunny::NetworkFailure => e
          e
        end

        it "raises a copy of the first one every time" do
          first  = raised_error
          second = raised_error

          [first, second].each do |raised|
            expect(raised).to be_a(Bunny::NetworkFailure)
            expect(raised).not_to equal(error)
            expect(raised.message).to eq(error.message)
            expect(raised.cause).to equal(framing_error)
          end
        end

        it "gives each copy the backtrace of the caller that raised it" do
          first  = raised_error
          second = raised_error

          expect(first.backtrace).not_to eq(second.backtrace)
          expect(error.backtrace).to be_nil
        end
      end

      context "when it has no stored errors" do
        it { expect { subject }.not_to raise_error }
      end
    end

    context "with a custom handler that stores errors" do
      let(:handler) { double("custom handler", all: [error]) }

      it { expect { subject }.not_to raise_error }
    end

    context "when the session error handler is a thread" do
      let(:handler) { Thread.current }

      it { expect { subject }.not_to raise_error }
    end

    context "when the connection does not expose its session error handler" do
      let(:connection) { double("connection") }

      it { expect { subject }.not_to raise_error }
    end
  end
end
