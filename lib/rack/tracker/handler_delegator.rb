class Rack::Tracker::HandlerDelegator
  class << self
    def method_missing(method_name, *args, &block)
      return super unless respond_to?(method_name)
      handler(method_name).track(method_name, *args, &block)
    end

    def respond_to?(method_name, include_private=false)
      handler(method_name).respond_to?(:track)
    end

    def handler(method_name)
      return method_name if method_name.kind_of?(Class)

      _handler = method_name.to_s.camelize
      ["Rack::Tracker::#{_handler}", _handler].detect do |const|
        begin
          return const.constantize
        rescue NameError
          false
        end
      end

      raise ArgumentError, "No such Handler: #{_handler}"
    end
  end
end
