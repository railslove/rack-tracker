class Rack::Tracker::Handler
  class_attribute :position_options
  self.position_options = { head: :append }

  attr_accessor :options
  attr_accessor :env

  def initialize(env, options = {})
    self.env = env
    self.options = options
    self.position_options = options[:position] if options[:position]
  end

  def events
    events = env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
    events.map{ |ev| "#{self.class}::#{ev['class_name']}".constantize.new(ev.except('class_name')) }
  end

  def render
    raise NotImplementedError.new('needs implementation')
  end

  def self.track(name, event)
    raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
  end

  def self.position(options=nil)
    self.position_options = options if options
    self.position_options
  end

  def position
    self.position_options
  end
end
