class Rack::Tracker::HandlerDelegator
  class << self
    def method_missing(method_name, *args, &block)
      return super unless respond_to?(method_name)
      handler(method_name).public_send(method_name, *args, &block)
    end

    def respond_to?(method_name, include_private=false)
      handler(method_name).respond_to?(method_name)
    end

    private

    def handler(method_name)
      _handler = method_name.to_s.classify.pluralize
      ["Rack::Tracker::#{_handler}", _handler].detect do |const|
        begin
          return const.constantize
        rescue NameError
          false
        end
      end
    end
  end
end
