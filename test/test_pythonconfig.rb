require "test/unit"
require "pythonconfig"

class TestConfigParser < Test::Unit::TestCase
  include PythonConfig
  def setup
    File.open(File.expand_path(File.join(File.dirname(__FILE__),"inputfile.ini")), "r") do |inp|
      @cfg = ConfigParser.new(inp)
    end
  end
  
  def test_sections
    assert_equal(["cool_section", "evil", "other_stuff"],@cfg.sections.keys.sort)
  end
  
  def test_basic_assignments
    assert_equal("true",@cfg.sections["cool_section"]["lame"])
    assert_equal("8.7",@cfg.sections["other_stuff"]["sweetness"])
    assert_equal("false",@cfg.sections["cool_section"]["cool"])
  end
  
  def test_multiline
    assert_equal("super good stuff that i bet you didn't think was possible did you now?", @cfg.sections["cool_section"]["multiline"])
  end
  
  def test_dot_accessor
    assert_equal(@cfg.sections["cool_section"], @cfg.cool_section)
  end
  
  def test_array_accessor
    assert_equal(@cfg.sections["cool_section"], @cfg["cool_section"])
  end
  
  def test_allow_empty
    assert_equal("", @cfg.sections["cool_section"]["empty"])
  end
  
  def test_interpolation
    assert_equal("your sweetness is 8.7!", @cfg.sections["other_stuff"]["output"])
  end
  
  def test_interpolation_recursion_exception
    assert_raises InterpolationTooDeepError do
      @cfg.sections["evil"]["firstone"]
    end
  end
  
  def test_add_section
    @cfg.add_section "new_section"
    assert_equal(["cool_section", "evil","new_section", "other_stuff"],@cfg.sections.keys.sort)
  end
  
  def test_casting
    assert_equal(8.7, @cfg.sections["other_stuff"]["sweetness", Float])
    assert_equal(true, @cfg.sections["cool_section"]["lame", "Boolean"])
    assert_equal(false, @cfg.sections["cool_section"]["cool", "bool"])
    assert_equal(["milks","egg","butter"], @cfg.sections["cool_section"]["list", Array])
  end
end
