require File.dirname(__FILE__) + "/test_helper.rb"

class SymbolTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_simple_symbol_tokenisation
    @sf.stubs(:source).returns(":test :test12 :_rah")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 5, line.tokens.size
    assert_equal ":test", line.tokens[0].content
    assert_equal :symbol, line.tokens[0].type
    assert_equal ":test12", line.tokens[2].content
    assert_equal :symbol, line.tokens[2].type
    assert_equal ":_rah", line.tokens[4].content
    assert_equal :symbol, line.tokens[4].type
  end

  def test_operator_symbol_tokenization
    @sf.stubs(:source).returns(":% :< :/ :<<")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal ":%", tokens[0].content
    assert_equal :symbol, tokens[0].type
    assert_equal ":<", tokens[2].content
    assert_equal :symbol, tokens[2].type
    assert_equal ":/", tokens[4].content
    assert_equal :symbol, tokens[4].type
    assert_equal ":<<", tokens[6].content
    assert_equal :symbol, tokens[6].type
  end

  def test_dynamic_symbol_tokenisation
    @sf.stubs(:source).returns(":'dynamic symbol' :\"dynamic symbol\"")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 3, tokens.size
    assert_equal :symbol, tokens[0].type
    assert_equal ":'dynamic symbol'", tokens[0].content
    assert_equal :symbol, tokens[2].type
    assert_equal ":\"dynamic symbol\"", tokens[2].content
  end

  def test_dynamic_symbol_tokenization2
    @sf.stubs(:source).returns("%s{rah}\n%s(rah)\n%s:rah:\n%s<rah<rah>rah>")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 2, tokens.size
    assert_equal :symbol, tokens[0].type
    assert_equal "%s{rah}", tokens[0].content
    tokens = @sf.lines[1].tokens
    assert_equal :symbol, tokens[0].type
    assert_equal "%s(rah)", tokens[0].content
    tokens = @sf.lines[2].tokens
    assert_equal :symbol, tokens[0].type
    assert_equal "%s:rah:", tokens[0].content
    tokens = @sf.lines[3].tokens
    assert_equal :symbol, tokens[0].type
    assert_equal "%s<rah<rah>rah>", tokens[0].content
  end
end
