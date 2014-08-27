class Rack::Tracker::Handler
  # options do
  #   cookie_domain "foo"
  # end
  class_attribute :position
  self.position = :head

  attr_accessor :options
  attr_accessor :env

  def initialize(env, options = {})
    self.env = env
    self.options = options
  end

  def events
    env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
  end

  def render
    raise ArgumentError.new('needs implementation')
  end
end
