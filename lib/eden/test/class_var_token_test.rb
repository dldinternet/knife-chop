require File.dirname(__FILE__) + "/test_helper.rb"

class IdentifierTokenTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_instance_var__tokenization
    @sf.stubs(:source).returns("@@token @@_token @@token2")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 5, line.tokens.size
    assert_equal "@@token", line.tokens[0].content
    assert_equal :classvar, line.tokens[0].type
    assert_equal "@@_token", line.tokens[2].content
    assert_equal :classvar, line.tokens[2].type
    assert_equal "@@token2", line.tokens[4].content
    assert_equal :classvar, line.tokens[4].type
  end

end
