class FacepalmPluginTest < Test::Unit::TestCase

  FP_IMG_REGEX = Regexp.new("http://facepalm.org/images/[0-9]+\.jpg")

  def setup
    @room = mock
    @msg = Globot::Message.new({ 'body' => '!facepalm' }, @room)
    @plugin = Globot::Plugin::Facepalm.new
  end

  def test_facepalm_reacts_to_valid_requests
    url = 'http://...'
    @plugin.expects(:facepalm).once.returns(url)
    @room.expects(:speak).with(url).once
    @plugin.handle @msg
  end

  def test_facepalm_only_reacts_to_valid_requests
    msg = Globot::Message.new({ 'body' => '!other' }, @room)
    @room.expects(:speak).never
    @plugin.handle msg
  end

  def test_retrieves_a_facepalm_image_url
    @room.expects(:speak).once.with { |v| v.match FP_IMG_REGEX }
    @plugin.handle @msg
  end

end
