require File.dirname(__FILE__) + "/test_helper.rb"

class IdentifierTokenTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_leading_underscore_identifier_tokenization
    @sf.stubs(:source).returns("    _token")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 2, line.tokens.size
    assert_equal "_token", line.tokens[1].content
    assert_equal :identifier, line.tokens[1].type
  end

  def test_multiple_token_tokenization
    @sf.stubs(:source).returns("token other_token")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 3, line.tokens.size
    assert_equal "token", line.tokens[0].content
    assert_equal :identifier, line.tokens[0].type
    assert_equal "other_token", line.tokens[2].content
    assert_equal :identifier, line.tokens[2].type
  end

  def test_keyword_tokenization_1
    @sf.stubs(:source).returns("__FILE__ __ENCODING__ __LINE__ BEGIN END")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 9, tokens.size
    assert_equal :__file__, tokens[0].type
    assert_equal "__FILE__", tokens[0].content
    assert_equal :__encoding__, tokens[2].type
    assert_equal "__ENCODING__", tokens[2].content
    assert_equal :__line__, tokens[4].type
    assert_equal "__LINE__", tokens[4].content
    assert_equal :begin_global, tokens[6].type
    assert_equal "BEGIN", tokens[6].content
    assert_equal :end_global, tokens[8].type
    assert_equal "END", tokens[8].content
  end

  def test_keyword_tokenization_2
    @sf.stubs(:source).returns("alias and begin break case class def do end")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 17, tokens.size
    assert_equal :alias, tokens[0].type
    assert_equal "alias", tokens[0].content
    assert_equal :and, tokens[2].type
    assert_equal "and", tokens[2].content
    assert_equal :begin, tokens[4].type
    assert_equal "begin", tokens[4].content
    assert_equal :break, tokens[6].type
    assert_equal "break", tokens[6].content
    assert_equal :case, tokens[8].type
    assert_equal "case", tokens[8].content
    assert_equal :class, tokens[10].type
    assert_equal "class", tokens[10].content
    assert_equal :def, tokens[12].type
    assert_equal "def", tokens[12].content
    assert_equal :do, tokens[14].type
    assert_equal "do", tokens[14].content
    assert_equal :end, tokens[16].type
    assert_equal "end", tokens[16].content
  end

  def test_keyword_tokenization_3
    @sf.stubs(:source).returns("else elsif ensure for false if in module")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 15, tokens.size
    assert_equal :else, tokens[0].type
    assert_equal "else", tokens[0].content
    assert_equal :elsif, tokens[2].type
    assert_equal "elsif", tokens[2].content
    assert_equal :ensure, tokens[4].type
    assert_equal "ensure", tokens[4].content
    assert_equal :for, tokens[6].type
    assert_equal "for", tokens[6].content
    assert_equal :false, tokens[8].type
    assert_equal "false", tokens[8].content
    assert_equal :if, tokens[10].type
    assert_equal "if", tokens[10].content
    assert_equal :in, tokens[12].type
    assert_equal "in", tokens[12].content
    assert_equal :module, tokens[14].type
    assert_equal "module", tokens[14].content
  end

  def test_keyword_tokenization_4
    @sf.stubs(:source).returns("next nil not or redo rescue retry return super")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 17, tokens.size
    assert_equal :next, tokens[0].type
    assert_equal "next", tokens[0].content
    assert_equal :nil, tokens[2].type
    assert_equal "nil", tokens[2].content
    assert_equal :not, tokens[4].type
    assert_equal "not", tokens[4].content
    assert_equal :or, tokens[6].type
    assert_equal "or", tokens[6].content
    assert_equal :redo, tokens[8].type
    assert_equal "redo", tokens[8].content
    assert_equal :rescue, tokens[10].type
    assert_equal "rescue", tokens[10].content
    assert_equal :retry, tokens[12].type
    assert_equal "retry", tokens[12].content
    assert_equal :return, tokens[14].type
    assert_equal "return", tokens[14].content
    assert_equal :super, tokens[16].type
    assert_equal "super", tokens[16].content
  end

  def test_keyword_tokenization_5
    @sf.stubs(:source).returns("then true undef unless until when while yield")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 15, tokens.size
    assert_equal :then, tokens[0].type
    assert_equal "then", tokens[0].content
    assert_equal :true, tokens[2].type
    assert_equal "true", tokens[2].content
    assert_equal :undef, tokens[4].type
    assert_equal "undef", tokens[4].content
    assert_equal :unless, tokens[6].type
    assert_equal "unless", tokens[6].content
    assert_equal :until, tokens[8].type
    assert_equal "until", tokens[8].content
    assert_equal :when, tokens[10].type
    assert_equal "when", tokens[10].content
    assert_equal :while, tokens[12].type
    assert_equal "while", tokens[12].content
    assert_equal :yield, tokens[14].type
    assert_equal "yield", tokens[14].content
  end
end
