class Rack::Tracker::Bing < Rack::Tracker::Handler

  class Conversion < OpenStruct
  end

  self.position = :body

  def tracker
    options[:tracker].respond_to?(:call) ? options[:tracker].call(env) : options[:tracker]
  end

end
