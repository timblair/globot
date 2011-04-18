module Globot
  module Plugin
    class Echo < Globot::Plugin::Base

      def initialize
        self.name = "Echo"
        self.description = "Echoes everything anyone says"
      end

      def handle(msg)
        puts "#{self.class.to_s} received: #{msg}"
      end

    end
  end
end