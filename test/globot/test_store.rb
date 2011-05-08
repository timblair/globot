class StoreTest < Test::Unit::TestCase

  # Test object for pushing in to the store
  class TestStoreObject; def to_s; 'faked'; end; end

  def setup
    @db = File.join(File.dirname(__FILE__), File.basename(__FILE__).split(/\./).first + ".db")
    @store = Globot::Store.new @db
  end

  def teardown
    File.delete @db
  end

  def test_new_store_instance_creates_database_file
    assert File.exists? @db
  end

  def test_automatically_created_database_file_has_plugin_data_table
    assert @store.data_table_exists?
  end

  def test_getting_an_empty_key_returns_nil
    assert_nil @store.get('ns', 'key')
  end

  def test_setting_then_getting_a_key_returns_the_key
    @store.set('ns', 'key', 'value')
    assert_equal 'value', @store.get('ns', 'key')
  end

  def test_setting_an_existing_value_overwrites_the_old_value
    @store.set('ns', 'key', 'value')
    @store.set('ns', 'key', 'value2')
    assert_equal 'value2', @store.get('ns', 'key')
  end

  def test_setting_stores_and_returns_to_s_on_the_value
    value = TestStoreObject.new
    ret = @store.set('ns', 'key', value)
    assert_equal 'faked', ret
    assert_equal 'faked', @store.get('ns', 'key')
  end

  def test_namespaces_allow_multiple_use_of_the_same_key
    @store.set('ns1', 'key', 'value1')
    @store.set('ns2', 'key', 'value2')
    assert_equal 'value1', @store.get('ns1', 'key')
    assert_equal 'value2', @store.get('ns2', 'key')
  end

  def test_deleting_an_existing_key_actually_deletes_it
    @store.set('ns', 'key', 'value')
    @store.delete('ns', 'key')
    assert_nil @store.get('ns', 'key')
  end

end
