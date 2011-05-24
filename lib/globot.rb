require 'rubygems'
require 'tinder'
require 'json'   # Tinder needs this internally for parsing the transcript
require 'logger'

# Turn SSL verification off to stop incredibly annoying "peer certificate
# won't be verified in this SSL session" warnings.
require 'ext/tinder/disable_ssl_verification'

module Globot
  VERSION = "0.0.1"

  # Autoloading goodness for speedy startups.  `autoload` isn't thread safe,
  # but we're not really worried about high concurrency access here.  We can
  # also abstract things slightly because all class names and file names are
  # consistent.  For more info on the thread-safety of `autoload` see
  # http://www.ruby-forum.com/topic/172385
  %w{ Bot Person Message Plugins Config Runner Store }.each do |klass|
    autoload klass.to_sym, "globot/#{klass.downcase}"
  end
  # `StoreProxy` is in the `store.rb` file, so doesn't conform to the naming
  # conventions that allow us to semi-automate things above.
  autoload :StoreProxy, "globot/store"

  class << self
    attr_accessor :logger, :config, :basepath

    # To make sure we've got access to the logger and configs at a module
    # level, we'll define them here with default values
    Globot.logger = Logger.new(nil)
    Globot.config = Globot::Config.instance
    Globot.basepath = File.expand_path('..', File.dirname(__FILE__))

    def init_logger(file, level)
      file = File.join(Globot.basepath, file) if file.class == String && !file.match(/^[\\\/]/)
      level = level.upcase! && %w{ DEBUG INFO WARN ERROR FATAL }.include?(level) ? level : "INFO"
      Globot.logger = Logger.new(file)
      Globot.logger.progname = 'globot'
      Globot.logger.level = Logger.const_get(level)
    end
  end
end
