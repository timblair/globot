class MessageTest < Test::Unit::TestCase

  def setup
    @simple_message = { 'body' => 'This is a test', 'type' => 'TestMessage', 'user' => { 'name' => 'Test User' }}
    @command_message = @simple_message.merge({ 'body' => '!cmd test' })
    @msg = Globot::Message.new(@simple_message, nil)
  end

  def test_command_is_parsed_correctly
    command, body = Globot::Message.parse_command(@command_message['body'])
    assert_equal 'cmd', command
    assert_equal 'test', body
  end

  def test_a_single_exclamation_mark_is_not_a_command
    command, body = Globot::Message.parse_command("!")
    assert_equal nil, command
    assert_equal '!', body
    command, body = Globot::Message.parse_command("! no command")
    assert_equal nil, command
    assert_equal '! no command', body
  end

  def test_command_and_body_are_set_correctly_on_init
    msg = Globot::Message.new(@command_message, nil)
    assert msg.command?
    assert_equal 'cmd', msg.command
    assert_equal 'test', msg.body
  end

  def test_whole_body_is_retained_when_command_is_parsed
    command, body = Globot::Message.parse_command('!cmd A Longer Test Message')
    assert_equal 'cmd', command
    assert_equal 'A Longer Test Message', body
  end

end
