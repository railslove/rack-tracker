module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          yield(Rack::Tracker::HandlerDelegator.new(respond_to?(:request) ? request.env : env))
        end
      end
    end
  end
end
