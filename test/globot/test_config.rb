class ConfigTest < Test::Unit::TestCase

  def setup
    # Because the config class is a singleton, we need to clear it
    # before each test, or we'll end up with variable leakage.
    Globot::Config.instance.clear
  end

  def test_config_is_an_indifferent_hash
    config = Globot::Config.instance
    config['key'] = 'value'
    assert_equal 'value', config[:key]
  end

  def test_acts_as_a_singleton_via_the_instance_method
    c = Globot::Config.instance
    Globot::Config.instance[:key] = 'value'
    assert c === Globot::Config.instance
    assert_equal 'value', Globot::Config.instance[:key]
  end

  def test_correctly_loads_an_external_yaml_file
    c = Globot::Config.load File.join(File.dirname(__FILE__), 'test_config.yml')
    assert c.include? :root
    assert c[:root].include? :sub1
    assert c[:root][:sub2].is_a? Array
  end

end
