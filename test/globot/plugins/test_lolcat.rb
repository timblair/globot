class LOLCatPluginTest < Test::Unit::TestCase

  def setup
    @room = mock
    @msg = Globot::Message.new({ 'body' => '!lolcat' }, @room)
    @plugin = Globot::Plugin::LOLCat.new
  end

  def test_lolcat_is_alive
    url = 'http://...'
    @plugin.expects(:kitteh).once.returns(url)
    @room.expects(:speak).with(url).once
    @plugin.handle @msg
  end

end
