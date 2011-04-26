module Globot
  module Plugin
    class Welcome < Globot::Plugin::Base

      SCRIPTS = [
        '%s is in da house!',
        'Welcome to the room, %s.',
        'Back again hey, %s?',
        '%s! Good to see you!'
      ]

      def initialize
        self.name = "Welcome"
        self.description = "Welcomes any new users who join the room."
      end

      def handle(msg)
        msg.reply(sprintf(SCRIPTS[rand(SCRIPTS.size)], msg.person)) if msg.type == 'EnterMessage'
      end

    end
  end
end
