describe Twingly::AMQP::Connection do
  subject { described_class }

  describe ".instance" do
    context "when called multiple times" do
      it "should return the same instance each time" do
        first_connection  = described_class.instance
        second_connection = described_class.instance

        expect(first_connection).to equal(second_connection)
      end
    end
  end
end
