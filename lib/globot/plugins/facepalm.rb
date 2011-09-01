require 'net/http'
require 'uri'

module Globot
  module Plugin
    class Facepalm < Globot::Plugin::Base

      BASE = "http://facepalm.org/"
      IMG  = "img.php"

      def setup
        self.name = "Facepalm"
        self.description = "Hang your head."
      end

      def handle(msg)
        msg.reply facepalm if msg.command == 'facepalm'
      end

      def facepalm
        uri = URI.parse(BASE + IMG)
        res =  Net::HTTP.get_response(uri)
        res.kind_of?(Net::HTTPRedirection) ? BASE + res.header['location'] : ""
      end

    end
  end
end
