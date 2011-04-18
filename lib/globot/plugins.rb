module Globot
  class Plugins

    # We track all available plugin *classes* (not instances) so we know which ones
    # we actually need to instantiate, and the active plugin *instances* which are
    # what we actually use to handle incoming messages.
    @plugins = []
    @active  = []

    # This class is effectively a manager object; everything in here is a class method.
    class << self
      attr_reader :active

      # Load and activate all available plugins.
      def load!
        # Each file should contain one or more subclasses of `Globot::Plugin::Base`
        # which, when loaded, will automatically register the class with this
        # class, meaning we have a collection of all available plugins.
        Dir[File.expand_path('../plugins/*.rb', __FILE__)].collect { |p| load p }

        # Once we've loaded and registered all plugins, we activate them all by
        # creating a new instance of each one.
        activate
      end

      # We can actually reload all plugins and reactivate them: handy for changes
      # to a plugin which don't affect the main codebase: we can just reload without
      # restarting the whole process.
      alias :reload :load!

      # We register the class names of all available plugins to allow us to
      # instantiate and activate those that we require.
      def register(klass)
        @plugins << klass
      end

      # Plugins are 'activated' by creating a new instance of each one based on
      # the list of class names we have registered.
      def activate
        @plugins.each { |p| @active << p.new }
      end

      # Each received message (including the room it was sent in) is passed off
      # to every active plugin, which deals with it as it sees fit (replying,
      # ignoring etc.)
      #
      # How we handle each message is dependant on it's type.  At the moment
      # we're only dealing with `Text` and `Paste` message types; everything
      # else is logged and ignored.  Other message types that may be taken
      # into consideration in the future are `Kick`, `Timestamp`, `Tweet`
      # and `Advertisement`.
      def handle(msg)
        case msg.type
          when "TextMessage", "PasteMessage"
            @active.each { |p| p.handle(msg) }
          else
            puts "Ignoring message of type #{msg.type}"
        end
      end

    end  # class << self
  end # class Plugins

  # All plugins must extend the `Globot::Plugin::Base` class.
  module Plugin
    class Base

      # Automatic callback function called whenever this class is subclassed
      # When a plugin class is `load`ed (or `require`d), the `#inherited`
      # method is automatically called and plugin is registered with the
      # `Globot::Plugins` manager class.
      def self.inherited(klass)
        Globot::Plugins.register(klass)
      end

      # The `#handle` method must be overridden in the plugin subclass; this
      # is where the plugin decides what to do with the message and how to
      # respond (if a response is actually required)
      def handle(msg)
        raise "The handle() method must be implemented in #{self.class.to_s}"
      end

      # For verbosity and ease of use, a plugin subclass can set `@name`
      # and `description` instance variables which are useful when listing
      # the loaded plugins.
      attr_accessor :name, :description

      # If a `@name` instance variable is not provided in the plugin
      # subclass, we default to using the class name.
      def name
        @name || self.class.to_s
      end

    end
  end

end