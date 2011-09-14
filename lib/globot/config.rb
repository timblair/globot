require 'singleton'
require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Globot
  class Config < ActiveSupport::HashWithIndifferentAccess
    include Singleton

    def self.load(path)
      instance.clear
      instance.merge! YAML::load(File.read(path))
    end

    def for_plugin(klass)
      klass = klass.to_s if klass.is_a? Class
      self[:globot][:plugins][klass.demodulize.underscore].dup.freeze rescue nil
    end

  end
end
