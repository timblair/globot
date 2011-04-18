module Globot
  class Plugins

    @plugins = []
    @active  = []

    class << self
      attr_reader :active

      def load!
        Dir[File.expand_path('../plugins/*.rb', __FILE__)].collect { |p| load p }
        activate
      end

      def register(plugin)
        @plugins << plugin
      end

      def activate
        @plugins.each { |p| @active << p.new }
      end
    end

  end

  module Plugin
    class Base
      def self.inherited(plugin)
        Globot::Plugins.register(plugin)
      end

      attr_accessor :name, :description

      def name
        @name || self.class.to_s
      end

    end
  end

end