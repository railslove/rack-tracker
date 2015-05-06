class Rack::Tracker::Handler
  class_attribute :container_tag, :container_position
  self.container_tag = :head
  self.container_position = :closing

  attr_accessor :options
  attr_accessor :env

  def initialize(env, options = {})
    self.env = env
    self.options             = options
    self.container_tag       = options[:container_tag]      if options.has_key?(:container_tag)
    self.container_position  = options[:container_position] if options.has_key?(:container_position)
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
end
