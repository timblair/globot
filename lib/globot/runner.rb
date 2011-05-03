require File.join(File.dirname(__FILE__), 'bot')
require 'yaml'

module Globot
  class Runner

    def initialize(opts)
      @config = YAML::load(File.read(opts[:config]))

      logger = { 'path' => 'tmp/globot.log', 'level' => :info }.merge(@config['globot']['logger'] || {})
      Globot.init_logger((opts[:daemonise] ? logger['path'] : STDOUT), logger['level'])

      Globot.logger.debug "Initing new runner with #{opts.inspect}"
      Globot.logger.debug "Config settings are #{@config.inspect}"
    end

    def start
      puts "Starting..."

      @bot = Globot::Bot.new(
                @config['campfire']['account'],
                @config['campfire']['api_key'],
                { :rooms => @config['globot']['rooms'] })

      @bot.start
    end

    def stop
      puts "Stopping..."
    end

    def status
      puts "Might be running"
    end
  end

end
