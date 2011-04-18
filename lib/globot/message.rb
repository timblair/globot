module Globot
  class Message

    attr_accessor :body, :type, :person, :room

    def initialize(msg, room)
      puts msg.inspect
      @body   = msg['body']
      @type   = msg['type']
      @person = msg['user']['name']
      @room   = room
    end

    # define methods for each of the basic functions
    %w(speak paste upload play).each do |cmd|
      define_method cmd do |msg|
        @room.send cmd, msg
      end
    end

    # another handy alternative for writing a new message
    alias :reply :speak

  end
end