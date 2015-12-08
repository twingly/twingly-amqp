require "twingly/amqp/session"

module Twingly
  module AMQP
    class Connection
      private_class_method :new

      @@lock     = Mutex.new
      @@instance = nil
      @@options  = {}

      def self.options=(options)
        @@options = options
      end

      def self.instance
        return @@instance if @@instance
        @@lock.synchronize do
          return @@instance if @@instance
          @@instance = Session.new(@@options).connection
        end
      end
    end
  end
end
