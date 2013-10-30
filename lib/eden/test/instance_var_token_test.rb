require File.dirname(__FILE__) + "/test_helper.rb"

class IdentifierTokenTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_instance_var_tokenization
    @sf.stubs(:source).returns("@token @_token @token2")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 5, line.tokens.size
    assert_equal "@token", line.tokens[0].content
    assert_equal :instancevar, line.tokens[0].type
    assert_equal "@_token", line.tokens[2].content
    assert_equal :instancevar, line.tokens[2].type
    assert_equal "@token2", line.tokens[4].content
    assert_equal :instancevar, line.tokens[4].type
  end

  # $' used as a global by Hprictot 0.6.164:lib/elements.rb[274]
  def test_global_var_tokenization
    @sf.stubs(:source).returns("$: $? $foo $1 $'")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 9, tokens.size
    assert_equal "$:", tokens[0].content
    assert_equal :globalvar, tokens[0].type
    assert_equal "$?", tokens[2].content
    assert_equal :globalvar, tokens[2].type
    assert_equal "$foo", tokens[4].content
    assert_equal :globalvar, tokens[4].type
    assert_equal "$1", tokens[6].content
    assert_equal :globalvar, tokens[6].type
    assert_equal "$'", tokens[8].content
    assert_equal :globalvar, tokens[8].type
  end

  # $` used as a global by Hprictot 0.6.164:lib/builder.rb[199]
  def test_global_var_tokenization_2
    @sf.stubs(:source).returns("$`")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 1, tokens.size
    assert_equal "$`", tokens[0].content
    assert_equal :globalvar, tokens[0].type
  end
end
