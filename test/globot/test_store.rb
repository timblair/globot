class StoreTest < Test::Unit::TestCase

  # Test object for pushing in to the store and testing proxy
  class TestStoreObject; end

  def setup
    @db = { :db => 11 }
    @store = Globot::Store.new @db
    @proxy = @store.proxy_for TestStoreObject.new
  end

  def teardown
    @store.redis.flushdb
  end

  def test_proxy_is_a_redis_namespace_instance
    assert @proxy.is_a? Redis::Namespace
  end

  def test_proxy_sets_namespace_based_on_plugin_given
    assert_equal TestStoreObject.new.class.name, @proxy.namespace
  end

  def test_proxy_returns_nil_for_an_empty_key
    assert_nil @proxy.get('key')
  end

  def test_proxy_returns_correct_key_after_being_set
    @proxy.set('key', 'value')
    assert_equal 'value', @proxy.get('key')
  end

  def test_proxy_overwrites_existing_key_when_setting_a_new_value
    @proxy.set('key', 'value')
    @proxy.set('key', 'value2')
    assert_equal 'value2', @proxy.get('key')
  end

  def test_proxy_does_not_return_key_after_it_has_been_deleted
    @proxy.set('key', 'value')
    @proxy.del('key')
    assert_nil @proxy.get('key')
  end

  def test_value_set_via_proxy_is_available_directly
    @proxy.set('key', 'value')
    raw_key = TestStoreObject.new.class.name + ":key"
    assert_equal 'value', @store.redis.get(raw_key)
  end

end
