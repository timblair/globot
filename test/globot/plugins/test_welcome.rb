class MockMessage
  attr_accessor :body, :type, :person
  def initialize(msg)
    @body   = msg['body']
    @type   = msg['type']
    @person = msg['user']['name']
  end
  def reply(str)
    str
  end
end

class WelcomePluginTest < Test::Unit::TestCase

  def setup
    Globot::Plugins.load!
    @msg = MockMessage.new({ 'body' => '', 'type' => 'EnterMessage', 'user' => { 'name' => 'Test User' }})
    @plugin = Globot::Plugin::Welcome.new
  end

  def test_welcome_message_is_output
    assert_match /#{@msg.person}/, @plugin.handle(@msg)
  end

end
