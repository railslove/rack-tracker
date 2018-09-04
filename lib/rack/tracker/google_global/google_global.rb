class Rack::Tracker::GoogleGlobal < Rack::Tracker::Handler
  self.allowed_tracker_options = [:cookie_domain, :user_id,
    :link_attribution, :allow_display_features, :anonymize_ip,
    :custom_map]

  def trackers
    options[:trackers].map do |tracker| 
      tracker[:id].respond_to?(:call) ? tracker.merge(id: tracker[:id].call(env)) : tracker
    end
  end

  def set_options
    @_set_options ||= build_set_options
  end

  private

  def build_set_options
    value = options[:set]
    value.respond_to?(:call) ? value.call(env) : value
  end
end
