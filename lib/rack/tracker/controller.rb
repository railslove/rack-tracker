module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          yield(Rack::Tracker::HandlerDelegator.new(env)).keys.map(&:to_sym)
        end
      end
    end
  end
end
