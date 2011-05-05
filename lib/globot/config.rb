require 'singleton'
require 'yaml'
require 'active_support/hash_with_indifferent_access'

module Globot
  class Config < ActiveSupport::HashWithIndifferentAccess
    include Singleton

    def self.load(path)
      instance.clear
      instance.merge! YAML::load(File.read(path))
    end

  end
end
