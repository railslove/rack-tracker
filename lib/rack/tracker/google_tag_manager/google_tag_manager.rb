class Rack::Tracker::GoogleTagManager < Rack::Tracker::Handler

  class Push < OpenStruct
    def write
      to_h.to_json
    end
  end

  def inject(response)
    # Sub! is enough, in well formed html there's only one head or body tag.
    # Block syntax need to be used, otherwise backslashes in input will mess the output.
    # @see http://stackoverflow.com/a/4149087/518204 and https://github.com/railslove/rack-tracker/issues/50
    response.sub! %r{<head>} do |m|
      m.to_s << self.render_head
    end
    response.sub! %r{<body>} do |m|
      m.to_s << self.render_body
    end
    response
  end

  def container
    options[:container].respond_to?(:call) ? options[:container].call(env) : options[:container]
  end

  def render_head
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager_head.erb') ).render(self)
  end

  def render_body
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager_body.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end
