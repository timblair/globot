require 'redis'
require 'redis-namespace'

module Globot
  class Store

    attr_reader :redis, :proxies

    def initialize(config)
      @redis = Redis.new(config)
      @proxies = {}
    end

    def proxy_for(plugin)
      namespace = plugin.class.name
      @proxies[namespace] ||= Redis::Namespace.new(namespace, :redis => @redis)
    end

  end
end
