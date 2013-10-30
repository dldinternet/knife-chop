require File.dirname(__FILE__) + "/test_helper.rb"

class NumberTokenizationTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new( "dummy.rb" )
  end

  def test_binary_tokenization
    @sf.stubs(:source).returns("b12345 0b01010 0b11056")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 6, line.tokens.size
    assert_equal "b12345", line.tokens[0].content
    assert_equal :identifier, line.tokens[0].type
    assert_equal "0b01010", line.tokens[2].content
    assert_equal :bin_literal, line.tokens[2].type
    assert_equal "0b110", line.tokens[4].content
    assert_equal :bin_literal, line.tokens[4].type
  end

  def test_hexadecimal_tokenisation
    @sf.stubs(:source).returns("0x0123 0x0F 0xDEADBEEF 0x0FRR")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 8, line.tokens.size
    assert_equal "0x0123", line.tokens[0].content
    assert_equal :hex_literal, line.tokens[0].type
    assert_equal "0x0F", line.tokens[2].content
    assert_equal :hex_literal, line.tokens[2].type
    assert_equal "0xDEADBEEF", line.tokens[4].content
    assert_equal :hex_literal, line.tokens[4].type
    assert_equal "0x0F", line.tokens[6].content
    assert_equal :hex_literal, line.tokens[6].type
  end

  def test_signed_tokenization
    @sf.stubs(:source).returns("-10 +4")
    @sf.tokenize!
    tokens = @sf.lines[0].tokens
    assert_equal 3, tokens.size
    assert_equal "-10", tokens[0].content
    assert_equal :dec_literal, tokens[0].type
    assert_equal "+4", tokens[2].content
    assert_equal :dec_literal, tokens[2].type
  end

  def test_decimal_tokenisation
    @sf.stubs(:source).returns("123 9123 0d1987")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 5, line.tokens.size
    assert_equal "123", line.tokens[0].content
    assert_equal :dec_literal, line.tokens[0].type
    assert_equal "9123", line.tokens[2].content
    assert_equal :dec_literal, line.tokens[2].type
    assert_equal "0d1987", line.tokens[4].content
    assert_equal :dec_literal, line.tokens[4].type
  end

  def test_float_tokenisation
    # TODO: Add test that 123.method doens't tokenize as float
    @sf.stubs(:source).returns("123.0")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 1, line.tokens.size
    assert_equal "123.0", line.tokens[0].content
    assert_equal :float_literal, line.tokens[0].type
  end


  def test_exponent_tokenisation
    @sf.stubs(:source).returns("123e24 1.032e-12 1.32e+12")
    @sf.tokenize!
    line = @sf.lines[0]
    assert_equal 5, line.tokens.size
    assert_equal "123e24", line.tokens[0].content
    assert_equal :exp_literal, line.tokens[0].type
    assert_equal "1.032e-12", line.tokens[2].content
    assert_equal :exp_literal, line.tokens[2].type
    assert_equal "1.32e+12", line.tokens[4].content
    assert_equal :exp_literal, line.tokens[4].type
  end
end
