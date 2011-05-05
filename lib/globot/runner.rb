require File.join(File.dirname(__FILE__), 'bot')
require 'yaml'

module Globot
  class Runner

    def initialize(opts)
      Globot::Config.load opts[:config]

      logger = { 'path' => 'tmp/globot.log', 'level' => :info }.merge(Globot.config['globot']['logger'] || {})
      Globot.init_logger((opts[:daemonise] ? logger['path'] : STDOUT), logger['level'])

      Globot.logger.debug "Initing new runner with #{opts.inspect}"
      Globot.logger.debug "Config settings are #{Globot.config.inspect}"
    end

    def start
      puts "Starting..."

      @bot = Globot::Bot.new(
                Globot.config['campfire']['account'],
                Globot.config['campfire']['api_key'],
                { :rooms => Globot.config['globot']['rooms'] })

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
