class DummyHandler < Rack::Tracker::Handler
  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/dummy.erb') ).render(self)
  end

  def dummy_alert
    env['tracker']['dummy']
  end
end

class BodyHandler < DummyHandler
  self.position body: :append
end

class BodyOpeningHandler < DummyHandler
  self.position body: :prepend
end

RSpec.describe Rack::Tracker do
  def app
    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "FOO"

      use Rack::Tracker do
        handler DummyHandler, { foo: 'head' }
        handler BodyHandler, { foo: 'body' }
        handler BodyOpeningHandler, { foo: 'body_opening' }
      end

      run lambda {|env|
        request = Rack::Request.new(env)
        case request.path
          when '/' then
            [200, {'Content-Type' => 'application/html'}, ['<head>Hello world</head>']]
          when '/body' then
            [200, {'Content-Type' => 'application/html'}, ['<body class="dummy">bob here</body>']]
          when '/body-head' then
            [200, {'Content-Type' => 'application/html'}, ['<head></head><body></body>']]
          when '/test.xml' then
            [200, {'Content-Type' => 'application/xml'}, ['Xml here']]
          when '/redirect' then
            [302, {'Content-Type' => 'application/html', 'Location' => '/'}, ['<body>redirection</body>']]
          when '/moved' then
            [301, {'Content-Type' => 'application/html', 'Location' => '/redirect'}, ['<body>redirection</body>']]
          else
            [404, 'Nothing here']
        end
      }
    end
  end
  subject { app }

  describe 'when head is present' do
    it 'injects the handler code' do
      get '/'
      expect(last_response.body).to include("alert('this is a dummy class');")
    end

    it 'will pass options to the Handler' do
      get '/'
      expect(last_response.body).to include("console.log('head');")
      expect(last_response.body).to_not include("console.log('body');")
      expect(last_response.body).to_not include("console.log('body_opening');")
    end

    it 'injects custom variables that was directly assigned' do
      get '/', {}, {'tracker' => { 'dummy' => 'foo bar'}}
      expect(last_response.body).to include("alert('foo bar');")
    end

    it 'injects custom variables that lives in the session' do
      get '/', {}, {'rack.session' => {'tracker' => { 'dummy' => 'bar foo'}}}
      expect(last_response.body).to include("alert('bar foo');")
    end
  end

  describe 'when body is present' do
    it 'will inject only the body handler code' do
      get '/body'
      expect(last_response.body).to include("console.log('body');")
      expect(last_response.body).to include("console.log('body_opening');")
      expect(last_response.body).to_not include("console.log('head');")
    end

    it 'will inject the handlers correctly using append or prepend' do
      get '/body'
      expect(last_response.body).to include("<body class=\"dummy\"><script type=\"text/javascript\">\n    alert('this is a dummy class');\n\n  console.log('body_opening');\n</script>")
      expect(last_response.body).to include("<script type=\"text/javascript\">\n    alert('this is a dummy class');\n\n  console.log('body');\n</script>\n</body>")
    end
  end

  describe 'when head and body is present' do
    it 'will pass options to the Handler' do
      get '/body-head'
      expect(last_response.body).to include("console.log('head');")
      expect(last_response.body).to include("console.log('body');")
      expect(last_response.body).to include("console.log('body_opening');")
    end
  end

  describe 'when a redirect' do
    it 'will keep the tracker attributes and show them on the new location' do
      get '/redirect', {}, { 'tracker' => { 'dummy' => 'Keep this!' } }
      follow_redirect!
      expect(last_response.body).to include("alert('Keep this!');")
    end

    it 'will keep the tracker attributes over multiple redirects' do
      get '/moved', {}, { 'tracker' => { 'dummy' => 'Keep this twice!' } }
      follow_redirect!
      expect(last_response.body).to include("alert('Keep this twice!');")
    end
  end

  describe 'when not html' do
    it 'will not inject the handler code' do
      get '/test.xml'

      expect(last_response.body).to_not include("alert('this is a dummy class');")
    end
  end
end
