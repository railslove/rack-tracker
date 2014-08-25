class Rack::Tracker::Handler
  # options do
  #   cookie_domain "foo"
  # end

  attr_accessor :options
  attr_accessor :env

  def initialize(env, options = {})
    self.env = env
    self.options = options
  end

  def render
    raise ArgumentError.new('needs implementation')
  end

  def events
    env.fetch('tracker', {})['google_analytics'] || []
  end
end
