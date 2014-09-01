module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          yield(Rack::Tracker::HandlerDelegator.new(env))
        end
      end
    end
  end
end
