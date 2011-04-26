# Custom Faraday middleware to force SSL verification to be OFF for every
# call.  The call to set the verification mode to `OpenSSL::SSL::VERIFY_NONE`
# is tucked away inside Faraday's `Net::HTTP` adaptor; to cleanest way to
# automatically set this is with a new piece of middleware.
require 'faraday'
module Globot
  module FaradayRequest
    class DisableSSLVerification < Faraday::Middleware

      def call(env)
        env[:ssl][:verify] = false
        @app.call env
      end

    end
  end
end

# Ideally, we could just override the `connection` method within the base
# `Tinder` class and tell the connection to use the new middleware:
#
#     alias_method :base_connection, :connection
#     def connection
#       @ssl_connection ||= base_connection do |conn|
#         conn.use Globot::FaradayRequest::IgnoreSSLVerification
#       end
#     end
#
# Unfortunately, the order of inclusion is important, and middleware which
# modifies the request has to come before the adaptor is defined, so the
# only way to do this is to completely override the `self.connection` and
# `self.raw_connection` methods, copying the existing middleware
# declarations, and adding our own at the beginning.
#
# TODO: Fork Tinder itself and add a new (optional) middleware to do this!
module Tinder
  class Connection

    class << self

      def connection
        @connection ||= Faraday::Connection.new do |conn|
          conn.use      Globot::FaradayRequest::DisableSSLVerification
          conn.use      Faraday::Request::ActiveSupportJson
          conn.adapter  Faraday.default_adapter
          conn.use      Tinder::FaradayResponse::RaiseOnAuthenticationFailure
          conn.use      Faraday::Response::ActiveSupportJson
          conn.use      Tinder::FaradayResponse::WithIndifferentAccess
          conn.headers['Content-Type'] = 'application/json'
        end
      end

      def raw_connection
        @raw_connection ||= Faraday::Connection.new do |conn|
          conn.use      Globot::FaradayRequest::DisableSSLVerification
          conn.adapter  Faraday.default_adapter
          conn.use      Tinder::FaradayResponse::RaiseOnAuthenticationFailure
          conn.use      Faraday::Response::ActiveSupportJson
          conn.use      Tinder::FaradayResponse::WithIndifferentAccess
        end
      end

    end
  end
end
