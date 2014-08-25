class Rack::Tracker::Facebook < Rack::Tracker::Handler

  # options do
  #   locale 'de_DE'
  #   app_id
  #   custom_audience_id
  # end

  # event do
  #   id
  #   value
  #   currency
  # end

  # position :body

  def event
    env[:rack_tracker][:facebook][:event] rescue {}
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/facebook.erb') ).render(self)
  end

end
