module Globot
  module Plugin
    class Echo < Globot::Plugin::Base

      def initialize
        self.name = "Echo"
        self.description = "Echoes everything anyone says"
      end

      def handle(msg)
        msg.reply msg.body
      end

    end
  end
end