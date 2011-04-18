module Globot
  module Plugin
    class Test < Globot::Plugin::Base

      def initialize
        self.name = "Test"
        self.description = "Doesn't do anything, just here for testing purposes"
      end

    end
  end
end