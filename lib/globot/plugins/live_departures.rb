require 'faraday'

module Globot
  module Plugin
    class LiveDepartures < Globot::Plugin::Base

      NAT_RAIL_HOST = 'http://ojp.nationalrail.co.uk'
      NAT_RAIL_PATH = '/en/s/ldb/liveTrainsJson'

      def initialize
        self.name = "Live Departures"
        self.description = "Live train departures between two given stations."
      end

      def connection
        @connection ||= Faraday.new(:url => NAT_RAIL_HOST) do |builder|
          builder.use Faraday::Response::ActiveSupportJson
          builder.adapter Faraday.default_adapter
        end
      end

      def handle(msg)
        return if msg.command != 'trains'
        stations = msg.body.split(/\s/)
        (msg.reply(help) && return) if stations.length != 2

        begin
          res = connection.get do |req|
            req.url NAT_RAIL_PATH
            req.params['departing']      = 'true'
            req.params['liveTrainsFrom'] = stations[0]
            req.params['liveTrainsTo']   = stations[1]
          end
        rescue Exception => e
          msg.reply "Couldn't find your train times... :("
          raise e
        end

        trains = res.body['trains'].collect do |t|
          # trains that are late have escaped HTML in the response
          t[3] = "Expected at #{t[3].sub('&lt;br/&gt; ', '(')})" if t[3] != 'On time'
          "#{t[1]} to #{t[2]}: #{t[3]}"
        end
        msg.paste trains.join("\n")
      end

      def help
        "Example Live Departures usage: !trains WNC SLO"
      end

    end
  end
end
