module Globot
  module Plugin
    class Welcome < Globot::Plugin::Base

      SCRIPTS = [
        '%s is in da house!',
        'Welcome to the room, %s.',
        'Back again hey, %s?',
        '%s! Good to see you!'
      # Plugins can be reloaded dynamically, and we don't want to redefine contants.
      ] unless self.const_defined?('SCRIPTS')

      def setup
        self.name = "Welcome"
        self.description = "Welcomes any new users who join the room."
      end

      def handle(msg)
        msg.reply(sprintf(SCRIPTS[rand(SCRIPTS.size)], msg.person.name)) if msg.type == 'EnterMessage'
      end

    end
  end
end
