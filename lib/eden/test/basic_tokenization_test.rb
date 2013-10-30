require File.dirname(__FILE__) + "/test_helper"

class BasicTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new("dummy.rb")
  end

  def test_should_tokenize_linebreak_escape
    @sf.stubs(:source).returns("puts \\\n  'rah'")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 4, tokens.size
    assert_equal :backslash, tokens[2].type
    assert_equal :newline, tokens[3].type
  end

  def test_should_tokenize_question_mark_character_literals
    @sf.stubs(:source).returns("?a ?} ?\u2332\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :character_literal, tokens[0].type
    assert_equal "?a", tokens[0].content
    assert_equal :character_literal, tokens[2].type
    assert_equal "?}", tokens[2].content
    assert_equal :character_literal, tokens[4].type
    assert_equal "?\u2332", tokens[4].content
  end
end
