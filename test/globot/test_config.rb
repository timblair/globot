class ConfigTest < Test::Unit::TestCase

  def setup
    # Because the config class is a singleton, we need to clear it
    # before each test, or we'll end up with variable leakage.
    Globot::Config.instance.clear
    # Load the default test settings for each test, as most require
    # them; we can manually clear the instance for those that don't.
    @config = Globot::Config.load File.join(File.dirname(__FILE__), 'test_config.yml')
  end

  def test_config_is_an_indifferent_hash
    @config['key'] = 'value'
    assert_equal 'value', @config[:key]
  end

  def test_acts_as_a_singleton_via_the_instance_method
    Globot::Config.instance[:key] = 'value'
    assert @config === Globot::Config.instance
    assert_equal 'value', Globot::Config.instance[:key]
  end

  def test_correctly_loads_an_external_yaml_file
    assert @config.include? :globot
    assert @config[:globot].include? :sub1
    assert @config[:globot][:sub2].is_a? Array
  end

  def test_plugin_settings_are_returned_correctly
    assert_equal "value", @config.for_plugin("plugin")
  end

  def test_plugin_settings_are_returned_correct_with_class_name
    assert_equal [1,2,3], @config.for_plugin(Globot::Config)
  end

  def test_nil_is_returned_for_plugin_with_no_config
    assert_nil @config.for_plugin("imaginary_plugin")
  end

end
