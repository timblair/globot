$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'mocha'
begin; require 'turn'; rescue LoadError; end

require 'globot'
Globot::Plugins.load!

# A mixin module to DRY up configuration setup for plugin tests.
# Make sure you `include Globot::Test::PluginTest` and call `super`
# from the `setup` method of your test, e.g.:
#
#     class MyPluginTest < Test::Unit::TestCase
#       include Globot::Test::PluginTest
#       def setup
#         super
#         # custom setup in here
#       end
#       # add your test cases
#     end
#
module Globot::Test
  module PluginTest
    def setup
      # Re-load any configuration.
      Globot::Config.load File.join(File.dirname(__FILE__), 'config.yml')
      # Clear the persistent store.
      Globot::Plugins.store.truncate!
    end
  end
end
