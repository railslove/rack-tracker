class Rack::Tracker::HandlerDelegator
  class << self
    def handler(method_name)
      new.handler(method_name)
    end
  end

  attr_accessor :env

  def initialize(env={})
    @env = env
  end

  def method_missing(method_name, *args, &block)
    if respond_to?(method_name)
      write_event(handler(method_name).track(method_name, *args, &block))
    else
      super
    end
  end

  def write_event(event)
    event.deep_stringify_keys! # for consistency
    if env.key?('tracker')
      self.env['tracker'].deep_merge!(event) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
    else
      self.env['tracker'] = event
    end
  end

  def respond_to?(method_name, include_private=false)
    handler(method_name).respond_to?(:track, include_private)
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
