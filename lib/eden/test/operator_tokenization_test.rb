require File.dirname(__FILE__) + "/test_helper.rb"

class OperatorTokenizationTest < Test::Unit::TestCase
 def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_equals_tokenization
    @sf.stubs(:source).returns("= == => === =~")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 9, tokens.size
    assert_equal :equals, tokens[0].type
    assert_equal "=", tokens[0].content
    assert_equal :equality, tokens[2].type
    assert_equal "==", tokens[2].content
    assert_equal :hash_rocket, tokens[4].type
    assert_equal "=>", tokens[4].content
    assert_equal :identity_equality, tokens[6].type
    assert_equal "===", tokens[6].content
    assert_equal :matches, tokens[8].type
    assert_equal "=~", tokens[8].content
  end

  def test_plus_tokenization
    @sf.stubs(:source).returns("+ += +@")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal :plus, tokens[0].type
    assert_equal "+", tokens[0].content
    assert_equal :plus_equals, tokens[2].type
    assert_equal "+=", tokens[2].content
    assert_equal :plus_at, tokens[4].type
    assert_equal "+@", tokens[4].content
  end

  def test_minus_tokenization
    @sf.stubs(:source).returns("- -= -@")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal :minus, tokens[0].type
    assert_equal "-", tokens[0].content
    assert_equal :minus_equals, tokens[2].type
    assert_equal "-=", tokens[2].content
    assert_equal :minus_at, tokens[4].type
    assert_equal "-@", tokens[4].content
  end

  def test_multiply_tokenization
    @sf.stubs(:source).returns("* *= ** **=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :multiply, tokens[0].type
    assert_equal "*", tokens[0].content
    assert_equal :multiply_equals, tokens[2].type
    assert_equal "*=", tokens[2].content
    assert_equal :exponent, tokens[4].type
    assert_equal "**", tokens[4].content
    assert_equal :exponent_equals, tokens[6].type
    assert_equal "**=", tokens[6].content
  end

  def test_divide_tokenization
    @sf.stubs(:source).returns("rah / gah")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal :divide, tokens[2].type
    assert_equal "/", tokens[2].content
  end
  
  def test_divide_equals_tokenization
    @sf.stubs(:source).returns("rah /= gah")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal tokens.size, 5
    assert_equal :divide_equals, tokens[2].type
    assert_equal "/=", tokens[2].content
  end

  def test_lt_tokenization
    @sf.stubs(:source).returns("< <= << <<= <=>")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 9, tokens.size
    assert_equal :lt, tokens[0].type
    assert_equal "<", tokens[0].content
    assert_equal :lte, tokens[2].type
    assert_equal "<=", tokens[2].content
    assert_equal :left_shift, tokens[4].type
    assert_equal "<<", tokens[4].content
    assert_equal :left_shift_equals, tokens[6].type
    assert_equal "<<=", tokens[6].content
    assert_equal :sort_operator, tokens[8].type
    assert_equal "<=>", tokens[8].content
  end

  def test_gt_tokenization
    @sf.stubs(:source).returns("> >= >> >>=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :gt, tokens[0].type
    assert_equal ">", tokens[0].content
    assert_equal :gte, tokens[2].type
    assert_equal ">=", tokens[2].content
    assert_equal :right_shift, tokens[4].type
    assert_equal ">>", tokens[4].content
    assert_equal :right_shift_equals, tokens[6].type
    assert_equal ">>=", tokens[6].content
  end

  def test_pipe_tokenization
    @sf.stubs(:source).returns("| |= || ||=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :bitwise_or, tokens[0].type
    assert_equal "|", tokens[0].content
    assert_equal :bitwise_or_equals, tokens[2].type
    assert_equal "|=", tokens[2].content
    assert_equal :logical_or, tokens[4].type
    assert_equal "||", tokens[4].content
    assert_equal :logical_or_equals, tokens[6].type
    assert_equal "||=", tokens[6].content
  end

  def test_pipe_tokenization
    @sf.stubs(:source).returns("& &= && &&=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :bitwise_and, tokens[0].type
    assert_equal "&", tokens[0].content
    assert_equal :bitwise_and_equals, tokens[2].type
    assert_equal "&=", tokens[2].content
    assert_equal :logical_and, tokens[4].type
    assert_equal "&&", tokens[4].content
    assert_equal :logical_and_equals, tokens[6].type
    assert_equal "&&=", tokens[6].content
  end

  def test_caret_tokenization
    @sf.stubs(:source).returns("^ ^=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 3, tokens.size
    assert_equal :caret, tokens[0].type
    assert_equal "^", tokens[0].content
    assert_equal :caret_equals, tokens[2].type
    assert_equal "^=", tokens[2].content
  end

  def test_modulo_tokenization
    @sf.stubs(:source).returns("% a %=")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal :modulo, tokens[0].type
    assert_equal "%", tokens[0].content
    assert_equal :modulo_equals, tokens[4].type
    assert_equal "%=", tokens[4].content
  end

  def test_bang_tokenization
    @sf.stubs(:source).returns("!= !~ !")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal :not_equals, tokens[0].type
    assert_equal "!=", tokens[0].content
    assert_equal :not_matches, tokens[2].type
    assert_equal "!~", tokens[2].content
    assert_equal :logical_not, tokens[4].type
    assert_equal "!", tokens[4].content
  end
end
