class Rack::Tracker::Handler
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
    raise NotImplementedError.new('needs implementation')
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

  def self.track(name, event)
    raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
  end
end
