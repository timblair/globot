$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
begin; require 'turn'; rescue LoadError; end

require 'globot'
