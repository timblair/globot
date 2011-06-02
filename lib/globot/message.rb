module Globot
  class Message

    attr_accessor :raw, :command, :body, :type, :person, :room

    def initialize(msg, room)
      @raw    = msg['body']
      @type   = msg['type']
      @person = Globot::Person.new msg['user'] if msg.has_key?('user') && !msg['user'].nil?
      @room   = room
      @command, @body = self.class.parse_command(@raw)
    end

    # Define methods for each of the basic functions: each dynamically
    # created method simply relays the given raw message body to the
    # appropriate handler within the Room that this message came from.
    # This means that we can only respond to a message in the same room
    # that is originates from.
    %w(speak paste upload play).each do |cmd|
      define_method cmd do |body|
        @room.send cmd, body
      end
    end

    # We'll also alias the strangely-named `speak` method to something
    # more sensible.
    alias :reply :speak

    # Did this message contain a command?
    def command?
      !@command.nil?
    end

    # Parse out a command command name as provided within the raw
    # message body, given by starting the message with an exclamation
    # mark and the command name, follwed by the rest of the message:
    #
    #     !command_name rest of message
    def self.parse_command(str)
      !str.nil? && str.match(/^![^\s]/) ?
        [ str[1..-1].split(/\s/).first, str.gsub(/^.*?\s+/, '') ] :
        [ nil, str || "" ]
    end

  end
end
