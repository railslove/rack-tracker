class Rack::Tracker::GoogleTagManager < Rack::Tracker::Handler

  class Push < OpenStruct
    def write
      to_h.to_json
    end
  end
  
  def container
    options[:container].respond_to?(:call) ? options[:container].call(env) : options[:container]
  end

  def render_head
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager_head.erb') ).render(self)
  end

  def render_body
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end

  def default_positions
    {
      before_head_close: :render_head,
      after_body_open: :render_body
    }
  end
end
