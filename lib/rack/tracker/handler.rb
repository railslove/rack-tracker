class Rack::Tracker::Handler
  class << self
    def process_track(env, method_name, *args, &block)
      new(env).write_event(track(method_name, *args, &block))
    end

    # overwrite me in the handler subclass if you need more control over the event
    def track(name, *event)
      { name.to_s => [event.last.merge('class_name' => event.first.to_s.classify)] }
    end
  end

  class_attribute :position
  self.position = :head

  class_attribute :allowed_tracker_options
  self.allowed_tracker_options = []

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
    events = env.fetch('tracker', {})[handler_name] || []
    events.map { |ev| "#{self.class}::#{ev['class_name']}".constantize.new(ev.except('class_name')) }
  end

  def render
    Tilt.new(File.join(File.dirname(__FILE__), handler_name, 'template', "#{handler_name}.erb") ).render(self)
  end

  def inject(response)
    # default to not inject this tracker if the DNT HTTP header is set
    # if the DO_NOT_RESPECT_THE_USERS_CHOICE_TO_OPT_OUT config is set the DNT header is ignored :( - please do respect the DNT header!
    if self.dnt_header_opt_out? && !self.options.has_key?(:DO_NOT_RESPECT_THE_USERS_CHOICE_TO_OPT_OUT)
      return response
    end
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

  def tracker_options
    @_tracker_options ||= {}.tap do |tracker_options|
      options.slice(*allowed_tracker_options).each do |key, value|
        if option_value = value.respond_to?(:call) ? value.call(env) : value
          tracker_options[tracker_option_key(key)] = tracker_option_value(option_value)
        end
      end
    end
  end

  # the request has set the DO NOT TRACK (DNT) and has opted to get not tracked (DNT=1)
  def dnt_header_opt_out?
    self.env['HTTP_DNT'] && self.env['HTTP_DNT'].to_s == '1'
  end

  private

  # Transformations to be applied to tracker option keys.
  # Override in descendants, if necessary.
  def tracker_option_key(key)
    key.to_sym
  end

  # Transformations to be applied to tracker option values.
  # Override in descendants, if necessary.
  def tracker_option_value(value)
    value
  end
end
