module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          event = Rack::Tracker::HandlerDelegator.instance_exec(&block)
          if env.key?('tracker')
            self.env = env['tracker'].deep_merge!(event)
          else
            self.env['tracker'] = event
          end
        end
      end
    end
  end
end
