class LiveDeparturePluginTest < Test::Unit::TestCase

  include Globot::Test::PluginTest

  def setup
    super
    @payload = { 'body' => '', 'user' => { 'id' => 1, 'name' => 'Test User' } }
    @room = mock
    @msg = Globot::Message.new(@payload, @room)
    @plugin = Globot::Plugin::LiveDepartures.new
  end

  def test_setting_a_default_route_stores_the_serialised_route
    route = %w{ WNC SLO }
    @plugin.store_default_for @msg.person, route
    assert_equal @plugin.default_for(@msg.person), route
  end

  def test_help_text_is_sent_if_required
    @room.expects(:paste).with(@plugin.help).once
    msg = Globot::Message.new({'body' => '!trains help'}, @room)
    @plugin.handle msg
  end

  def test_warning_reply_sent_if_no_default_route_is_set
    payload = @payload.merge({'body' => '!trains default'})
    msg = Globot::Message.new(payload, @room)
    @room.expects(:speak).with(regexp_matches(/no default route/)).once
    @plugin.handle msg
  end

  def test_setting_a_default_route_stores_the_route_and_reponds
    route = %w{ RDG PAD }
    payload = @payload.merge({'body' => "!trains default #{route.join(' ')}"})
    @room.expects(:speak).with(regexp_matches(/#{route.join(' to ')}/)).once
    @plugin.handle Globot::Message.new(payload, @room)
    assert_equal @plugin.default_for(@msg.person), route
  end

  def test_default_route_returned_when_default_is_set
    route = %w{ WNC SLO }
    @plugin.store_default_for @msg.person, route
    payload = @payload.merge({'body' => '!trains default'})
    @room.expects(:speak).with(regexp_matches(/#{route.join(' to ')}/)).once
    @plugin.handle Globot::Message.new(payload, @room)
  end

  def test_warning_reply_sent_if_no_locations_or_default
    payload = @payload.merge({'body' => '!trains'})
    msg = 
    @room.expects(:speak).with(regexp_matches(/don't have a default/)).once
    @plugin.handle Globot::Message.new(payload, @room)
  end

  def test_with_locations_attempts_remote_lookup_and_reponds_to_no_results
    route = %w{ RDG PAD }
    payload = @payload.merge({'body' => "!trains #{route.join(' ')}"})
    @plugin.expects(:find_departures).with(*route).once.returns([])
    @room.expects(:speak).with(regexp_matches(/couldn't find any trains/)).once
    @plugin.handle Globot::Message.new(payload, @room)
  end

  def test_with_default_attempts_remote_lookup_and_reponds_to_no_results
    route = %w{ RDG PAD }
    @plugin.store_default_for @msg.person, route
    payload = @payload.merge({'body' => "!trains"})
    @plugin.expects(:find_departures).with(*route).once.returns([])
    @room.expects(:speak).with(regexp_matches(/couldn't find any trains/)).once
    @plugin.handle Globot::Message.new(payload, @room)
  end

  # TODO: A proper test of `LiveDepartures#find_departures` with mocks and
  # stubs in place so a live HTTP request isn't made, but it still tests
  # the full call.

  def test_cleaning_departures_removes_html
    assert_equal(
      [[nil, nil, nil, 'Expected at 12:34 (10 mins late)']],
      @plugin.clean_departures([[nil, nil, nil, '12:34 &lt;br/&gt; 10 mins late']])
    )
  end

  def test_formatting_departures_lays_things_out_nicely
    assert_equal(
      ["12:34 to Reading                        On time"],
      @plugin.format_departures([[nil, '12:34', 'Reading', 'On time']])
    )
  end

end
