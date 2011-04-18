module Globot
  module Plugin
    class Echo < Globot::Plugin::Base

      def initialize
        self.name = "Echo"
        self.description = "Echoes everything anyone says"
      end

    end
  end
end