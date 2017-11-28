class Rack::Tracker::GoogleGlobal < Rack::Tracker::Handler
  ALLOWED_TRACKER_OPTIONS = [:cookie_domain, :user_id, 
    :link_attribution, :allow_display_features, :anonymize_ip]

  def trackers
    options[:trackers].map do |tracker| 
      tracker[:id].respond_to?(:call) ? tracker.merge(id: tracker[:id].call(env)) : tracker
    end
  end

  def tracker_options(tracker)
    return {} if tracker[:options].blank?
    {}.tap do |options|
      tracker[:options].slice(*ALLOWED_TRACKER_OPTIONS).each do |key, value|
        option_value = value.respond_to?(:call) ? value.call(env) : value
        if !option_value.nil?
          options[key] = option_value
        end
      end
    end
  end
end
