module Globot
  class Bot

    attr_accessor :id, :email, :name

    def initialize(domain, token, opts = {})
      Globot::Plugins.load!
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

      # join each room
      threads = []
      @rooms.each do |room|
        # `Room#listen` blocks, so run each one in a separate thread
        threads << Thread.new do
          begin
            room.listen do |msg|
              if !msg.nil? && msg['user']['id'] != id   # ignore messages from myself
                Globot::Plugins.handle Globot::Message.new(msg, room)
              end
            end
          rescue Exception => e
            trace = e.backtrace.join("\n")
            puts "ERROR: #{e.message}\n#{trace}"
          end
        end
      end
      threads.each { |t| t.join }
    end

  end
end
