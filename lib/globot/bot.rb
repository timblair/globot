module Globot
  class Bot

    attr_accessor :id, :email, :name

    def initialize(domain, token, opts = {})
      Globot::Plugins.load!(self)
      connect(domain, token, opts)
    end

    def connect(domain, token, opts)
      @campfire = Tinder::Campfire.new(domain, { :token => token })

      me     = @campfire.me
      @id    = me['id']
      @email = me['email_address']
      @name  = me['name']
      puts "Logged in as #{name} <#{email}> [ID##{id}]"

      @rooms = @campfire.rooms
      @rooms = @rooms.select { |r| opts[:rooms].include? r.name } if !opts[:rooms].nil?
    end

    def start

      room = @rooms.first   # just one room for now
      room.listen do |msg|
        begin
          if !msg.nil? && msg['user']['id'] != id   # ignore messages from myself
            Globot::Plugins.handle Globot::Message.new(msg, room)
          end
        rescue Exception => e
          trace = e.backtrace.join("\n")
          puts "ERROR: #{e.message}\n#{trace}"
        end
      end

    end

  end
end
