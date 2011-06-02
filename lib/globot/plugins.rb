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
        # We can load plugins from multiple locations to make organisation easier.
        # Each file should contain one or more subclasses of `Globot::Plugin::Base`
        # which, when loaded, will automatically register the class with this
        # class, meaning we have a collection of all available plugins.
        paths = Globot.config.for_plugin('loadpath') || File.join(%w{ lib globot plugins })
        paths.each do |path|
          Globot.logger.debug "Loading plugins from #{path}"
          Dir[File.expand_path(File.join(path, '*.rb'), Globot.basepath)].collect { |p| load p }
        end

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
        Globot.logger.debug "Registered plugin: #{klass}"
        @plugins << klass
      end

      # Plugins are 'activated' by creating a new instance of each one based on
      # the list of class names we have registered.
      def activate
        @plugins.each { |p| @active << p.new(Globot.config.for_plugin(p)) }
      end

      # Each received message (including the room it was sent in) is passed off
      # to every active plugin, which deals with it as it sees fit (replying,
      # ignoring etc.)
      def handle(msg)
        Globot.logger.debug "--> [#{msg.type}#{msg.person.nil? ? '' : ' / ' + msg.person.name}] #{msg.raw}"
        @active.each { |p| p.handle(msg) }
      end

      # A persistent store is provided for plugins to use as they will.  The
      # location of the SQLite database is stored in the special `database`
      # plugin key.
      def store
        @store ||= Globot::Store.new(Globot.config.for_plugin('database'))
      end

    end  # class << self
  end # class Plugins

  module Plugin
    # All plugins must extend the `Globot::Plugin::Base` class.
    class Base

      # Automatic callback function called whenever this class is subclassed
      # When a plugin class is `load`ed (or `require`d), the `#inherited`
      # method is automatically called and plugin is registered with the
      # `Globot::Plugins` manager class.
      def self.inherited(klass)
        Globot::Plugins.register(klass)
      end

      # On initialisation, any config defined for this plugin will be
      # passed in.  The config should be stored in the YAML config file
      # under the key structure `globot\plugins\my_plugin_name`, where
      # `my_plugin_name` is the underscored, demodularised version of
      # the plugin class.  For example, a plugin of the class
      # `Globot::Plugins::MyTestPlugin` would use the configuration
      # data stored under `my_test_plugin`.
      def initialize(config = nil)
        @config = config
        setup
      end

      # Rather than overriding the `initializing` method in the subclass,
      # we'll use a non-standard `setup` method which can be used to set
      # things like plugin name and description, plus any other setup
      # that may be required.
      def setup
      end

      # The `#handle` method must be overridden in the plugin subclass; this
      # is where the plugin decides what to do with the message and how to
      # respond (if a response is actually required)
      def handle(msg)
        raise "The handle() method must be implemented in #{self.class.to_s}"
      end

      # For verbosity and ease of use, a plugin subclass can set `@name`
      # and `@description` instance variables which are useful when listing
      # the loaded plugins.
      attr_accessor :name, :description, :config

      # If a `@name` instance variable is not provided in the plugin
      # subclass, we default to using the class name.
      def name
        @name || self.class.name
      end

      private

      # Provides a KVP style persistent store for data for the plugin.
      # All direct access is abstracted away into three simple commands:
      # `set`, `get` and `del`.  When `set` is called, the value actually
      # stored (and returned from future `get` calls) is the `to_s`
      # version of whatever object is given.  Example usage:
      #
      #     store.get 'my_key'           # => nil
      #     store.set 'my_key', 'value'  # => true
      #     store.get 'my_key'           # => 'value'
      #     store.del 'my_key'           # => true
      #     store.del 'my_key'           # => false
      def store
        @store ||= Globot::StoreProxy.new(Globot::Plugins.store, self)
      end

    end # class Base
  end # module Plugin

end
