class Rack::Tracker::Handler
  class << self
    def process_track(env, method_name, *args, &block)
      new(env).write_event(track(method_name, *args, &block))
    end

    def track(name, event)
      raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
    end
  end

  class_attribute :position
  self.position = :head

  attr_accessor :options
  attr_accessor :env

  # Allow javascript escaping in view templates
  include Rack::Tracker::JavaScriptHelper

  def initialize(env, options = {})
    self.env = env
    self.options  = options
    self.position = options[:position] if options.has_key?(:position)
  end

  def events
    events = env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
    events.map{ |ev| "#{self.class}::#{ev['class_name']}".constantize.new(ev.except('class_name')) }
  end

  def render
    Tilt.new(File.join(File.dirname(__FILE__), handler_name, 'template', "#{handler_name}.erb") ).render(self)
  end

  def inject(response)
    # Sub! is enough, in well formed html there's only one head or body tag.
    # Block syntax need to be used, otherwise backslashes in input will mess the output.
    # @see http://stackoverflow.com/a/4149087/518204 and https://github.com/railslove/rack-tracker/issues/50
    response.sub! %r{</#{self.position}>} do |m|
      self.render << m.to_s
    end
    response
  end

  def write_event(event)
    event.deep_stringify_keys! # for consistent hash access use strings (keys from the session are always strings anyway)
    if env.key?('tracker')
      self.env['tracker'].deep_merge!(event) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
    else
      self.env['tracker'] = event
    end
  end

  def handler_name
    self.class.name.demodulize.underscore
  end
end
