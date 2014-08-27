class DummyHandler < Rack::Tracker::Handler

  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/dummy.erb') ).render(self)
  end

  def dummy_alert
    env['tracker']['dummy']
  end

end

RSpec.describe Rack::Tracker do
  def app
    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "FOO"

      use Rack::Tracker do
        handler DummyHandler, { foo: 'BAZBAZ' }
      end

      run lambda {|env|
        request = Rack::Request.new(env)
        case request.path
          when '/' then
            [200, {'Content-Type' => 'application/html'}, ['<head>Hello world</head>']]
          when '/body' then
            [200, {'Content-Type' => 'application/html'}, ['<body>bob here</body>']]
          when '/test.xml' then
            [200, {'Content-Type' => 'application/xml'}, ['Xml here']]
          when '/redirect' then
            [302, {'Content-Type' => 'application/html', 'Location' => '/'}, ['<body>redirection</body>']]
          else
            [404, 'Nothing here']
        end
      }
    end
  end
  subject { app }

  describe 'when html and head is present' do
    it 'injects the handler code' do
      get '/'
      expect(last_response.body).to include("alert('this is a dummy class');")
    end

    it 'will pass options to the Handler' do
      get '/'
      expect(last_response.body).to include("console.log('BAZBAZ');")
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

  describe 'when html and head is missing' do
    it 'will not inject the handler code' do
      get '/body'
      expect(last_response.body).to_not include("alert('this is a dummy class');")
    end
  end

  describe 'when a redirect' do
    it 'will keep the tracker attributes and show them on the new location' do
      get '/redirect', {}, { 'tracker' => { 'dummy' => 'Keep this!' } }
      follow_redirect!
      expect(last_response.body).to include("alert('Keep this!');")
    end
  end

  describe 'when not html' do
    it 'will not inject the handler code' do
      get '/test.xml'

      expect(last_response.body).to_not include("alert('this is a dummy class');")
    end
  end
end
