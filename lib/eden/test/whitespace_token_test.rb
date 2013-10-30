require File.dirname(__FILE__) + "/test_helper.rb"

class WhitespaceTokenTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_leading_whitespace_tokenization
    @sf.stubs(:source).returns("    token")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 2, line.tokens.size
    assert_equal "    ", line.tokens[0].content
    assert_equal :whitespace, line.tokens[0].type
  end

  def test_leading_whitespace_tab_tokenization
    @sf.stubs(:source).returns("\t\ttoken")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 2, line.tokens.size
    assert_equal "\t\t", line.tokens[0].content
    assert_equal :whitespace, line.tokens[0].type
  end

  def test_leading_whitespace_multiple_space_tokenization
    @sf.stubs(:source).returns("\t token")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 2, line.tokens.size
    assert_equal "\t ", line.tokens[0].content
    assert_equal :whitespace, line.tokens[0].type
  end

  def test_trailing_whitespace_tokenization
    @sf.stubs(:source).returns("token    ")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 2, line.tokens.size
    assert_equal "    ", line.tokens[1].content
    assert_equal :whitespace, line.tokens[1].type
  end

  def test_interstitial_whitespace_tokenization
    @sf.stubs(:source).returns("token token")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 3, line.tokens.size
    assert_equal " ", line.tokens[1].content
    assert_equal :whitespace, line.tokens[1].type
  end

  def test_comment_tokenization
    @sf.stubs(:source).returns("token # Comment Rah Rah Rah\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 4, tokens.size
    assert_equal "# Comment Rah Rah Rah", tokens[2].content
    assert_equal :comment, tokens[2].type
    assert_equal "\n", tokens[3].content
    assert_equal :newline, tokens[3].type
  end
end
