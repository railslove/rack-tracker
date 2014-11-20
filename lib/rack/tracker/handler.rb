class Rack::Tracker::Handler
  class_attribute :position
  self.position = :head

  attr_accessor :options
  attr_accessor :env

  def initialize(env, options = {})
    self.env = env
    self.options  = options
    self.position = options[:position] if options.has_key?(:position)
  end

  def events
    env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
  end

  def render
    raise NotImplementedError.new('needs implementation')
  end

  def self.track(name, event)
    raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
  end
end
