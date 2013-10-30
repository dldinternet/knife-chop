require File.dirname(__FILE__) + "/test_helper.rb"

class ArrayLiteralTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_array_literal_tokenization
    @sf.stubs(:source).returns("%w{rah rah rah}\n%w<rah <rah> rah>")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 2, tokens.size
    assert_equal :array_literal, tokens[0].type
    assert_equal "%w{rah rah rah}", tokens[0].content
    tokens = @sf.lines[1].tokens
    assert_equal :array_literal, tokens[0].type
    assert_equal "%w<rah <rah> rah>", tokens[0].content
  end

  def test_should_not_expand_delimited_array_literal
    @sf.stubs(:source).returns("%w{rah \#{@inst} rah}\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 2, tokens.size
    assert_equal :array_literal, tokens[0].type
    assert_equal "%w{rah \#{@inst} rah}", tokens[0].content
  end

  def test_should_tokenize_expanded_array_literal
    @sf.stubs(:source).returns("%W{rah \#{@inst} rah}\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :array_literal, tokens[0].type
    assert_equal "%W{rah \#", tokens[0].content
    assert_equal :lcurly, tokens[1].type
    assert_equal :instancevar, tokens[2].type
    assert_equal "@inst", tokens[2].content
    assert_equal :rcurly, tokens[3].type
    assert_equal :array_literal, tokens[4].type
    assert_equal " rah}", tokens[4].content
  end
end
