module Globot
  class Plugins

    @plugins = []   # all available plugin classes
    @active  = []   # activated plugin instances

    # this class is effectively a manager object; everything in here is a class method
    class << self
      attr_reader :active

      # find all plugin files and load them
      def load!(bot = nil)
        # each file should contain one or more subclasses of Globot::Plugin::Base
        # which, when loaded, will automatically register the class with this
        # class, meaning we have a collection of all plugins
        Dir[File.expand_path('../plugins/*.rb', __FILE__)].collect { |p| load p }

        # once we've loaded and registered all plugins, we activate them all by
        # creating a new instance of each one (also adding a reference to the
        # Globot::Bot instance)
        activate(bot)
      end

      # register a given plugin class
      def register(klass)
        @plugins << klass
      end

      # activate all plugins by creating a new instance of each one
      def activate(bot = nil)
        @plugins.each do |klass|
          p = klass.new
          p.bot = bot if !bot.nil?
          @active << p
        end
      end

      def handle(msg)
        @active.each { |p| p.handle(msg) }
      end
    end

  end

  module Plugin
    class Base

      # automatic callback function called whenever this class is subclassed
      def self.inherited(klass)
        Globot::Plugins.register(klass)
      end

      def handle(msg)
        raise "The handle() method must be implemented in #{self.class.to_s}"
      end

      attr_accessor :name, :description
      attr_writer :bot

      def name
        @name || self.class.to_s
      end

    end
  end

end