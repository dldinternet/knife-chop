require File.dirname(__FILE__) + "/test_helper.rb"
require File.dirname(__FILE__) + "/../lib/eden/formatters/white_space_cleaner.rb"

class WhiteSpaceCleanerTest < Test::Unit::TestCase
  
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_should_not_strip_whitespace_when_not_configured
    WhiteSpaceCleaner.configure do |c|
      c.remove_trailing_whitespace false
    end

    @sf.stubs(:source).returns("def function     \n  return nil  \nend\n")
    @sf.tokenize!
    WhiteSpaceCleaner.format( @sf )
    assert_equal "def function     \n", @sf.lines[0].joined_tokens
    assert_equal "  return nil  \n", @sf.lines[1].joined_tokens
    assert_equal "end\n", @sf.lines[2].joined_tokens
  end

  def test_should_strip_whitespace
    WhiteSpaceCleaner.configure do |c|
      c.remove_trailing_whitespace true
    end

    @sf.stubs(:source).returns("def function     \n  return nil  \nend\n")
    @sf.tokenize!
    WhiteSpaceCleaner.format( @sf )
    assert_equal "def function\n", @sf.lines[0].joined_tokens
    assert_equal "  return nil\n", @sf.lines[1].joined_tokens
    assert_equal "end\n", @sf.lines[2].joined_tokens
  end
end
