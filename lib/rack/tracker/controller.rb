module Rack
  class Tracker
    module Controller
      def tracker(&block)
        if block_given?
          self.env.fetch('tracker', {}).deep_merge!(instance_eval(&block))
        end
      end

      def method_missing(method_name, *args, &block)
        return super unless respond_to?(method_name)
        # TODO
      end

      def respond_to?(method_name, include_private=false)
        return true if find_handler(method_name.to_s)
        super
      end

      private


      def find_handler(method_name)
        handler = method_name.classify.pluralize
        ["Rack::Tracker::#{handler}", handler].detect do |const|
          begin
            const.constantize and const.constantize.respond_to?(method_name)
          rescue NameError
            false
          end
        end
      end
    end
  end
end
