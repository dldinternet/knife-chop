require File.dirname(__FILE__) + "/test_helper.rb"

class SingleCharacterTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_single_character_tokenisation
    @sf.stubs(:source).returns("<>~!@% ^&*()[]{}|.: ;=? +-")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 26, line.tokens.size
    assert_equal "<", line.tokens[0].content
    assert_equal :lt, line.tokens[0].type
    assert_equal ">", line.tokens[1].content
    assert_equal :gt, line.tokens[1].type
    assert_equal "~", line.tokens[2].content
    assert_equal :tilde, line.tokens[2].type
    assert_equal "!", line.tokens[3].content
    assert_equal :logical_not, line.tokens[3].type
    assert_equal "@", line.tokens[4].content
    assert_equal :at, line.tokens[4].type
    assert_equal "%", line.tokens[5].content
    assert_equal :modulo, line.tokens[5].type
    assert_equal "^", line.tokens[7].content
    assert_equal :caret, line.tokens[7].type
    assert_equal "&", line.tokens[8].content
    assert_equal :bitwise_and, line.tokens[8].type
    assert_equal "*", line.tokens[9].content
    assert_equal :multiply, line.tokens[9].type
    assert_equal "(", line.tokens[10].content
    assert_equal :lparen, line.tokens[10].type
    assert_equal ")", line.tokens[11].content
    assert_equal :rparen, line.tokens[11].type
    assert_equal "[", line.tokens[12].content
    assert_equal :lsquare, line.tokens[12].type
    assert_equal "]", line.tokens[13].content
    assert_equal :rsquare, line.tokens[13].type
    assert_equal "{", line.tokens[14].content
    assert_equal :lcurly, line.tokens[14].type
    assert_equal "}", line.tokens[15].content
    assert_equal :rcurly, line.tokens[15].type
    assert_equal "|", line.tokens[16].content
    assert_equal :bitwise_or, line.tokens[16].type
    assert_equal ".", line.tokens[17].content
    assert_equal :period, line.tokens[17].type
    assert_equal ":", line.tokens[18].content
    assert_equal :colon, line.tokens[18].type
    assert_equal ";", line.tokens[20].content
    assert_equal :semicolon, line.tokens[20].type
    assert_equal "=", line.tokens[21].content
    assert_equal :equals, line.tokens[21].type
    assert_equal "?", line.tokens[22].content
    assert_equal :question_mark, line.tokens[22].type    
    assert_equal "+", line.tokens[24].content
    assert_equal :plus, line.tokens[24].type    
    assert_equal "-", line.tokens[25].content
    assert_equal :minus, line.tokens[25].type    
  end

  def test_period_tokenization
    @sf.stubs(:source).returns("... .. .")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal "...", tokens[0].content
    assert_equal :range_inc, tokens[0].type    
    assert_equal "..", tokens[2].content
    assert_equal :range_exc, tokens[2].type    
    assert_equal ".", tokens[4].content
    assert_equal :period, tokens[4].type    
  end

  def test_colon_tokenization
   @sf.stubs(:source).returns(":test :: : ")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal ":test", tokens[0].content
    assert_equal :symbol, tokens[0].type    
    assert_equal "::", tokens[2].content
    assert_equal :scope_res, tokens[2].type    
    assert_equal ":", tokens[4].content
    assert_equal :colon, tokens[4].type    
  end

end
