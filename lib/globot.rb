require 'rubygems'
require 'tinder'
require 'json'   # Tinder needs this internally for parsing the transcript
require 'globot/bot'
require 'globot/message'
require 'globot/plugins'
require 'globot/runner'

# Turn SSL verification off to stop incredibly annoying "peer certificate
# won't be verified in this SSL session" warnings.
require 'ext/tinder/disable_ssl_verification'

module Globot
  VERSION = "0.0.1"
end
