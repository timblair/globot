require 'singleton'
require 'yaml'
require 'active_support/hash_with_indifferent_access'
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
      key = klass.demodulize.underscore
      # TODO: There must be a better way to test for the
      # existence of nested has keys, right?
      return nil if self[:globot].nil?
      return nil if self[:globot][:plugins].nil?
      return nil if self[:globot][:plugins][key].nil?
      self[:globot][:plugins][key].dup.freeze
    end

  end
end
