require "rack"
require "tilt"
require "active_support/core_ext/hash"
require "active_support/json"

require "rack/tracker/version"
require "rack/tracker/extensions"
require 'rack/tracker/railtie' if defined?(Rails)
require "rack/tracker/handler"
require "rack/tracker/handler_delegator"
require "rack/tracker/controller"
require "rack/tracker/google_analytics/google_analytics"
require "rack/tracker/facebook/facebook"

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

      env[EVENT_TRACKING_KEY] = {} unless env[EVENT_TRACKING_KEY]

      session = env["rack.session"]
      if response.ok?
        # Write out the events now

        # Get any stored events from a redirection
        stored_events = session.delete(EVENT_TRACKING_KEY) if session

        env[EVENT_TRACKING_KEY].deep_merge!(stored_events) { |key, old, new| Array.wrap(old) + Array.wrap(new) } unless stored_events.nil?
      elsif response.redirection? && session
        # Store the events until next time
        env["rack.session"][EVENT_TRACKING_KEY] = env[EVENT_TRACKING_KEY]
      end

      @body.each { |fragment| response.write inject(env, fragment) }
      @body.close if @body.respond_to?(:close)

      response.finish
    end

    private

    def html?; @headers['Content-Type'] =~ /html/; end

    def inject(env, response)
      @handler = @handlers.first.name.new(env, @handlers.first.options)
      response.gsub(%r{</head>}, @handler.render + "</head>")
    end

    class HandlerSet
      Handler = Struct.new(:name, :options)

      def initialize(&block)
        @handlers = []
        self.instance_exec(&block) if block_given?
      end

      def handler(name, opts = {}, &block)
        @handlers << Handler.new(Rack::Tracker::HandlerDelegator.handler(name), opts)
      end

      def first
        @handlers.first
      end

      def to_a
        @handlers
      end

    end
  end
end
