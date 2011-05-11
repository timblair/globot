require 'faraday'

module Globot
  module Plugin
    class LiveDepartures < Globot::Plugin::Base

      def setup
        self.name = "Live Departures"
        self.description = "Live train departures between two given stations."
      end

      def help
        # TODO: Why doesn't this line match?
        #     File.read(__FILE__).match('=' + 'begin(.+)=end')[0].strip
        @help ||= File.read(__FILE__).split(/=begin/).last.gsub(/=end/, '').strip
      end

      def connection
        @connection ||= Faraday.new(:url => service_host) do |builder|
          builder.use Faraday::Response::ActiveSupportJson
          builder.adapter Faraday.default_adapter
        end
      end

      def handle(msg)
        # This plugin only handles the `!trains` command.
        return if msg.command != 'trains'
        args = msg.body.split(/\s/)

        # Is the first argument a recognised sub-command?
        case args.first
          # A user can set a default route, request trains for their default route, or
          # display the default route they have set.
          when 'default'
            # We don't care about the command any more.
            args.shift
            if args.length == 2
              store_default_for msg.person, args
              msg.reply "#{msg.person.name}: your default route is " + args.join(' to ') + "."
            else
              route = default_for msg.person
              if !route.nil?
                msg.reply "#{msg.person.name}: your default route is " + route.join(' to ') + "."
              else
                msg.reply "#{msg.person.name}: you have no default route set."
              end
            end

          # A `help` sub-command just relies with the plgin help.
          when 'help'
            msg.paste help

          # If we're not processing a sub-command, then we want train times.
          else
            # If a start point and destination are both provided then grab times for them.
            if args.length == 2
              trains = find_departures(args.shift, args.shift)
            # If we've not specific locations, use the user's default.
            else
              route = default_for msg.person
              if route.nil?
                msg.reply "#{msg.person.name}: you don't have a default route set.  Set one like this: !trains default WNC SLO"
              else
                trains = find_departures(*route) rescue []
              end
            end

            # Reply appropriately if a lookup has actually occurred.
            if !trains.nil?
              if trains.length > 0
                msg.paste format_departures(trains).join("\n")
              else
                msg.reply "Sorry #{msg.person.name}: I couldn't find any trains for you."
              end
            end
        end
      end

      def find_departures(from, to)
        trains = []
        begin
          trains = connection.get do |req|
            req.url service_path
            req.params['departing']      = 'true'
            req.params['liveTrainsFrom'] = from
            req.params['liveTrainsTo']   = to
          end.body['trains']
        rescue Exception => e
          Globot.logger.error e
        end
        clean_departures trains
      end

      def clean_departures(trains)
        trains.each do |t|
          # trains that are late have escaped HTML in the response
          t[3] = "Expected at #{t[3].sub('&lt;br/&gt; ', '(')})" if t[3].match(/late/)
        end
      end

      def format_departures(trains)
        trains.collect do |t|
          "%-5s to %-30s %s" % [ t[1], t[2], t[3] ]
        end
      end

      # Users can store a default route by sending a `default` command, e.g.:
      #
      #     !trains default WNC SLO    #=> New default route set for this user
      #     !trains                    #=> Returns live departures for default route
      #     !trains default            #=> Shows user's default route
      def store_default_for(person, route)
        store.set "default:#{person.id}", route.to_json
      end
      def default_for(person)
        JSON.parse(store.get("default:#{person.id}")) rescue nil
      end

      private

      # The endpoint host and path for accessing the National Rail data.  Doesn't
      # use constants so we can live-reload the plugins.
      def service_host
        'http://ojp.nationalrail.co.uk'
      end
      def service_path
        '/service/ldb/liveTrainsJson'
      end

    end
  end
end

=begin
Train Departures gives you live departure times for the next few
trains between the two stations you provide, for example:

    !trains WNC SLO            #=> Shows departures from WNC to SLO

You can also set a default route (for you only) as follows:

    !trains default WNC SLO    #=> Sets your default route
    !trains                    #=> Returns departures for your default route
    !trains default            #=> Shows your stored default route
=end
