module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          Rack::Tracker::HandlerDelegator.new(env).instance_exec(&block)
        end
      end
    end
  end
end
