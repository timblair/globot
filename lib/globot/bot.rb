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
      Globot.logger.info "Logged in as #{name} <#{email}> [ID##{id}]"

      @rooms = @campfire.rooms
      @rooms = @rooms.select { |r| opts[:rooms].include? r.name } if !opts[:rooms].nil?
    end

    # Start listening to all messages on the configured rooms.  Takes each
    # message and palms it off to the plugin manager for processing.
    def start
      threads = []
      @rooms.each do |room|
        Globot.logger.info "Joining room: #{room.name}"
        # `Room#listen` blocks, so run each one in a separate thread
        threads << Thread.new do
          room.listen do |msg|
            begin
              # Ignore messages originating from the bot's user
              if !msg.nil? && (msg['user'].nil? || msg['user']['id'] != id)
                Globot::Plugins.handle Globot::Message.new(msg, room)
              end
            rescue Exception => e
              trace = e.backtrace.join("\n")
              Globot.logger.error "#{e.message}\n#{trace}"
            end
          end
        end
      end
      threads.each { |t| t.join }
    end

  end
end
