# This module is extracted from Rails to provide reliable javascript escaping.
#
# @see https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/javascript_helper.rb
module Rack::Tracker::JavaScriptHelper

  JS_ESCAPE_MAP = {
      '\\' => '\\\\',
      '</' => '<\/',
      "\r\n" => '\n',
      "\n" => '\n',
      "\r" => '\n',
      '"' => '\\"',
      "'" => "\\'"
  }

  JS_ESCAPE_MAP["\342\200\250".force_encoding(Encoding::UTF_8).encode!] = '&#x2028;'
  JS_ESCAPE_MAP["\342\200\251".force_encoding(Encoding::UTF_8).encode!] = '&#x2029;'

  # Escapes carriage returns and single and double quotes for JavaScript segments.
  #
  # Also available through the alias j(). This is particularly helpful in JavaScript
  # responses, like:
  #
  #   $('some_element').replaceWith('<%=j render 'some/element_template' %>');
  def escape_javascript(javascript)
    if javascript
      javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) { |match| JS_ESCAPE_MAP[match] }
    else
      ''
    end
  end

  alias_method :j, :escape_javascript
end
