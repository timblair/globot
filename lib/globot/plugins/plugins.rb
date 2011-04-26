module Globot
  module Plugin
    class Plugins < Globot::Plugin::Base

      def initialize
        self.name = "Plugins"
        self.description = "Lists the active plugins."
      end

      def handle(msg)
        if msg.command == 'plugins'
          plugins = []
          Globot::Plugins.active.each do |p|
            plugins << "#{p.name}: #{p.description}"
          end
          msg.paste plugins.join("\n")
        end
      end

    end
  end
end
