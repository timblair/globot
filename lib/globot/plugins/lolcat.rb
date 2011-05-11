require 'open-uri'
require 'hpricot'

module Globot
  module Plugin
    class LOLCat < Globot::Plugin::Base

      def setup
        self.name = "LOLCat"
        self.description = "Shows a random picture of a beautiful kitteh."
      end

      def handle(msg)
        msg.reply kitteh if msg.command == 'lolcat'
      end

      def kitteh
        (Hpricot(open('http://icanhascheezburger.com/?random'))/'div.entry img').first['src']
      end

    end
  end
end
