module Rack
  class Tracker
    module Controller
      def tracker(&block)
        yield(Rack::Tracker::HandlerDelegator.new(env)) if block_given?
      end
    end
  end
end
