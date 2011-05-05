require 'rubygems'
require 'tinder'
require 'json'   # Tinder needs this internally for parsing the transcript
require 'logger'

require 'globot/bot'
require 'globot/person'
require 'globot/message'
require 'globot/plugins'
require 'globot/config'
require 'globot/runner'

# Turn SSL verification off to stop incredibly annoying "peer certificate
# won't be verified in this SSL session" warnings.
require 'ext/tinder/disable_ssl_verification'

module Globot
  VERSION = "0.0.1"

  class << self
    attr_accessor :logger, :config

    # To make sure we've got access to the logger and configs at a module
    # level, we'll define them here with default values
    Globot.logger = Logger.new(nil)
    Globot.config = Globot::Config.instance

    def init_logger(file, level)
      file = File.join(File.dirname(__FILE__), '..', file) if file.class == String && !file.match(/^[\\\/]/)
      level = level.upcase! && %w{ DEBUG INFO WARN ERROR FATAL }.include?(level) ? level : "INFO"
      Globot.logger = Logger.new(file)
      Globot.logger.progname = 'globot'
      Globot.logger.level = Logger.const_get(level)
    end
  end
end
