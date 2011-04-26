require File.join(File.dirname(__FILE__), 'bot')
require 'yaml'
require 'logger'

module Globot

  class << self
    attr_accessor :logger

    def init_logger(file, level)
      file = File.join(File.dirname(__FILE__), '..', '..', file) if file.class == String && file.match(/^[\\\/]/)
      Globot.logger = Logger.new(file)
      Globot.logger.progname = 'globot'
      # TODO: pass the correct log level through from the config
      Globot.logger.level = Logger::DEBUG
    end
  end

  class Runner

    def initialize(opts)
      @config = YAML::load(File.read(opts[:config]))

      logger = (@config['globot']['logger'] || {}).merge({ 'path' => 'tmp/globot.log', 'level' => :info })
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
