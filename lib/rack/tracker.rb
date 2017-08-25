require "rack"
require "tilt"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/hash"
require "active_support/json"
require "active_support/inflector"

require "rack/tracker/version"
require "rack/tracker/extensions"
require "rack/tracker/javascript_helper"
require 'rack/tracker/railtie' if defined?(Rails)
require "rack/tracker/handler"
require "rack/tracker/handler_delegator"
require "rack/tracker/controller"
require "rack/tracker/google_analytics/google_analytics"
require "rack/tracker/google_tag_manager/google_tag_manager"
require "rack/tracker/google_adwords_conversion/google_adwords_conversion"
require "rack/tracker/facebook/facebook"
require "rack/tracker/facebook_pixel/facebook_pixel"
require "rack/tracker/vwo/vwo"
require "rack/tracker/go_squared/go_squared"
require "rack/tracker/criteo/criteo"
require "rack/tracker/zanox/zanox"
require "rack/tracker/hotjar/hotjar"

module Rack
  class Tracker
    EVENT_TRACKING_KEY = 'tracker'

    def initialize(app, &block)
      @app = app
      @handlers = Rack::Tracker::HandlerSet.new(&block)
    end

    def call(env)
      @status, @headers, @body = @app.call(env)
      return [@status, @headers, @body] unless html?
      response = Rack::Response.new([], @status, @headers)

      env[EVENT_TRACKING_KEY] ||= {}

      if session = env["rack.session"]
        env[EVENT_TRACKING_KEY].deep_merge!(session.delete(EVENT_TRACKING_KEY) || {}) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
      end

      if response.redirection? && session
        session[EVENT_TRACKING_KEY] = env[EVENT_TRACKING_KEY]
      end

      @body.each { |fragment| response.write inject(env, fragment) }
      @body.close if @body.respond_to?(:close)

      response.finish
    end

    private

    def html?; @headers['Content-Type'] =~ /html/; end

    def inject(env, response)
      @handlers.each(env) do |handler|
        handler.inject(response)
      end
      response
    end

    class HandlerSet
      Handler = Struct.new(:klass, :configuration) do
        def init(env)
          klass.new(env, configuration)
        end
      end

      def initialize(&block)
        @handlers = []
        instance_exec(&block) if block_given?
      end

      # setup the handler class with configuration options and make it ready for receiving the env during injection
      #
      # usage:
      #
      #   use Rack::Tracker do
      #     handler :google_analytics, { tracker: 'U-XXXXX-Y' }
      #   end
      #
      def handler(name, configuration = {}, &block)
        # we need here "something" (which is atm the handler struct)
        # to postpone the initialization of the handler,
        # to give it the env and configuration options when the result of the handler is injected into the response.
        @handlers << Handler.new(Rack::Tracker::HandlerDelegator.handler(name), configuration)
      end

      def each(env = {}, &block)
        @handlers.map { |h| h.init(env) }.each(&block)
      end
    end
  end
end
