class WelcomePluginTest < Test::Unit::TestCase

  def setup
    @payload = { 'body' => '', 'type' => 'EnterMessage', 'user' => { 'name' => 'Test User' }}
    @room = mock
    @msg = Globot::Message.new(@payload, @room)
    Globot::Plugins.load!
    @plugin = Globot::Plugin::Welcome.new
  end

  def test_welcome_message_is_output
    @room.expects(:speak).with(regexp_matches(/#{@msg.person.name}/)).once
    @plugin.handle @msg
  end

end
