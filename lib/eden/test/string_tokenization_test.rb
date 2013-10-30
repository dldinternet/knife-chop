require File.dirname(__FILE__) + "/test_helper.rb"

class StringTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_single_quote_string_tokenisation
    @sf.stubs(:source).returns("'test' 'te\\'st' 'te\\\\st' 'te\"st'")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :single_q_string, tokens[0].type
    assert_equal "'test'", tokens[0].content
    assert_equal :single_q_string, tokens[2].type
    assert_equal "'te\\'st'", tokens[2].content
    assert_equal :single_q_string, tokens[4].type
    assert_equal "'te\\\\st'", tokens[4].content
    assert_equal :single_q_string, tokens[6].type
    assert_equal "'te\"st'", tokens[6].content
  end

  def test_backquote_string_tokenisation
    @sf.stubs(:source).returns("`exec`")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 1, tokens.size
    assert_equal :backquote_string, tokens[0].type
    assert_equal "`exec`", tokens[0].content
  end

  def test_backquote_string_interpolation
    @sf.stubs(:source).returns("`exec \#\{\"cmd\"\}`")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal "`exec \#", tokens[0].content
    assert_equal :lcurly, tokens[1].type
    assert_equal "\"cmd\"", tokens[2].content
    assert_equal :rcurly, tokens[3].type
    assert_equal "`", tokens[4].content
    assert_equal :backquote_string, tokens[4].type
  end

  def test_should_tokenize_unterminated_backquote_string
    @sf.stubs(:source).returns("`exec")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 1, tokens.size
    assert_equal :backquote_string, tokens[0].type
    assert_equal "`exec", tokens[0].content
  end

  def test_double_quote_string_tokenisation
    @sf.stubs(:source).returns('"test" "end')
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 3, tokens.size
    assert_equal :double_q_string, tokens[0].type
    assert_equal '"test"', tokens[0].content
    assert_equal :double_q_string, tokens[2].type
    assert_equal '"end', tokens[2].content
  end

  def test_double_quote_string_escaping
    @sf.stubs(:source).returns('"te\\"st" "test\\\\test"')
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 3, tokens.size
    assert_equal :double_q_string, tokens[0].type
    assert_equal '"te\\"st"', tokens[0].content
    assert_equal :double_q_string, tokens[2].type
    assert_equal '"test\\\\test"', tokens[2].content
  end

  def test_quoted_expanded_literal_string_tokenization
    @sf.stubs(:source).returns("%(test)\n%Q(test)")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 2, tokens.size
    assert_equal "%(test)", tokens[0].content
    assert_equal :double_q_string, tokens[0].type
    tokens = @sf.lines[1].tokens
    assert_equal "%Q(test)", tokens[0].content
    assert_equal :double_q_string, tokens[0].type
  end

  def test_should_expand_expanded_literal_strings
    @sf.stubs(:source).returns("%Q(rah\#{@ivar}rah)")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal "%Q(rah\#", tokens[0].content
    assert_equal :double_q_string, tokens[0].type
    assert_equal :lcurly, tokens[1].type
    assert_equal "@ivar", tokens[2].content
    assert_equal :instancevar, tokens[2].type
    assert_equal :rcurly, tokens[3].type
    assert_equal "rah)", tokens[4].content
    assert_equal :double_q_string, tokens[4].type
  end

  def test_should_not_expand_non_expanded_literal_strings
    @sf.stubs(:source).returns("%q(rah\#{@ivar}rah)")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 1, tokens.size
    assert_equal "%q(rah\#{@ivar}rah)", tokens[0].content
    assert_equal :single_q_string, tokens[0].type
  end
  
  def test_double_quote_string_interpolation
    @sf.stubs(:source).returns("\"str\#{ @inst }str\"")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 7, tokens.size
    assert_equal :double_q_string, tokens[0].type
    assert_equal '"str#', tokens[0].content
    assert_equal :lcurly, tokens[1].type
    assert_equal '{', tokens[1].content
    assert_equal :instancevar, tokens[3].type
    assert_equal '@inst', tokens[3].content
    assert_equal :rcurly, tokens[5].type
    assert_equal '}', tokens[5].content
    assert_equal :double_q_string, tokens[6].type
    assert_equal 'str"', tokens[6].content
  end

  def test_string_interpolation_at_end
    @sf.stubs(:source).returns("\"str\#{ @inst }\"\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 8, tokens.size
    assert_equal :double_q_string, tokens[0].type
    assert_equal '"str#', tokens[0].content
    assert_equal :double_q_string, tokens[6].type
    assert_equal '"', tokens[6].content
  end

  def test_string_interpolation_with_class_instance_vars
    @sf.stubs(:source).returns("\"str\#@inst moar \#@@var\"\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal '"str#', tokens[0].content
    assert_equal :double_q_string, tokens[0].type
    assert_equal '@inst', tokens[1].content
    assert_equal :instancevar, tokens[1].type
    assert_equal ' moar #', tokens[2].content
    assert_equal :double_q_string, tokens[2].type
    assert_equal '@@var', tokens[3].content
    assert_equal :classvar, tokens[3].type
    assert_equal '"', tokens[4].content
    assert_equal :double_q_string, tokens[4].type
  end

  def test_string_interpolation_with_global_vars
    @sf.stubs(:source).returns("\"str\#$1\"\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 4, tokens.size
    assert_equal '"str#', tokens[0].content
    assert_equal :double_q_string, tokens[0].type
    assert_equal '$1', tokens[1].content
    assert_equal :globalvar, tokens[1].type
    assert_equal '"', tokens[2].content
    assert_equal :double_q_string, tokens[2].type
  end
  
  def test_delimited_backquote_string_tokenization
    @sf.stubs(:source).returns("%x{rah --e}")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 1, tokens.size
    assert_equal :backquote_string, tokens[0].type
    assert_equal "%x{rah --e}", tokens[0].content
  end

  def test_should_expand_backquote_string_delimited_literals
    @sf.stubs(:source).returns("%x(rah\#{@rah})")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 5, tokens.size
    assert_equal "%x(rah\#", tokens[0].content
    assert_equal :backquote_string, tokens[0].type
    assert_equal :lcurly, tokens[1].type
    assert_equal "@rah", tokens[2].content
    assert_equal :instancevar, tokens[2].type
    assert_equal :rcurly, tokens[3].type
    assert_equal ")", tokens[4].content
    assert_equal :backquote_string, tokens[4].type
  end

  def test_heredoc_tokenization
    @sf.stubs(:source).returns("str = <<HEREDOC\nLorem Ipsum\nHEREDOC\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<HEREDOC", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "Lorem Ipsum\nHEREDOC", tokens[0].content
    assert_equal :newline, tokens[1].type
  end

  def test_heredoc_tokenization_2
    @sf.stubs(:source).returns("str = <<-HEREDOC\nLorem Ipsum\nHEREDOC\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<-HEREDOC", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "Lorem Ipsum\nHEREDOC", tokens[0].content
    assert_equal :newline, tokens[1].type
  end

  # Because the heredoc delimiter must be on a line by itself, the heredoc
  # delimiter can appear in the heredoc itself without terminating it.
  def test_heredoc_tokenization_with_amgibuous_delimiter
    @sf.stubs(:source).returns(<<-SOURCE)
var = <<WARNING
WARNING Blah Blah Blah
And something more
WARNING
SOURCE
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal "<<WARNING", tokens[4].content
    assert_equal :heredoc_delimiter, tokens[4].type
    tokens = @sf.lines[1].tokens
    assert_equal 2, tokens.size
    assert_equal "WARNING Blah Blah Blah\nAnd something more\nWARNING", tokens[0].content
    assert_equal :heredoc_body, tokens[0].type
  end

  def test_heredoc_tokenization_empty_heredoc
    @sf.stubs(:source).returns("str = <<-HEREDOC\nHEREDOC\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<-HEREDOC", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "HEREDOC", tokens[0].content
    assert_equal :newline, tokens[1].type
  end
  
  def test_heredoc_tokeniztion_with_single_quote_delimiter
    @sf.stubs(:source).returns("str = <<'HERE DOC'\nLorem Ipsum\n'HERE DOC'\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<'HERE DOC'", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "Lorem Ipsum\n'HERE DOC'", tokens[0].content
    assert_equal :newline, tokens[1].type
  end

  def test_heredoc_tokeniztion_with_double_quote_delimiter
    @sf.stubs(:source).returns("str = <<\"HERE DOC\"\nLorem Ipsum\n\"HERE DOC\"\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<\"HERE DOC\"", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "Lorem Ipsum\n\"HERE DOC\"", tokens[0].content
    assert_equal :newline, tokens[1].type
  end

  def test_heredoc_tokeniztion_with_backquote_delimiter
    @sf.stubs(:source).returns("str = <<`HERE DOC`\nLorem Ipsum\n`HERE DOC`\n")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 6, tokens.size
    assert_equal :heredoc_delimiter, tokens[4].type
    assert_equal "<<`HERE DOC`", tokens[4].content
    tokens = @sf.lines[1].tokens
    assert_equal :heredoc_body, tokens[0].type
    assert_equal "Lorem Ipsum\n`HERE DOC`", tokens[0].content
    assert_equal :newline, tokens[1].type
  end
end
