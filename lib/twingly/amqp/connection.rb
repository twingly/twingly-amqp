require "twingly/amqp"

module Twingly
  module AMQP
    class Connection
      private_class_method :new

      @@lock     = Mutex.new
      @@instance = nil

      def self.options=(options)
        warn "[DEPRECATION] `options=` is deprecated. " \
          "Please use configuration block: `Twingly::AMQP.configure` instead."

        Twingly::AMQP.configure do |config|
          config.connection_options = options
        end
      end

      def self.instance
        return @@instance if @@instance
        @@lock.synchronize do
          return @@instance if @@instance
          options = Twingly::AMQP.configuration.connection_options
          @@instance = Session.new(options).connection
        end
      end
    end
  end
end
