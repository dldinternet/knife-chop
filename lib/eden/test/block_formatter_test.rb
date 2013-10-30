require File.dirname(__FILE__) + "/test_helper.rb"
require File.dirname(__FILE__) + "/../lib/eden/formatters/block_formatter"

class BlockFormatterTest < Test::Unit::TestCase
  def setup
    @sf = Eden::SourceFile.new("dummy.rb")
  end

  def test_should_add_spaces_in_block
    @sf.stubs(:source).returns("things.map {|th|th+1}\n")
    @sf.tokenize!
    BlockFormatter.format( @sf )
    assert_equal @sf.lines[0].joined_tokens, "things.map { |th|th+1 }\n"
  end

  def test_should_not_change_block_when_disabled
    BlockFormatter.configure do |b|
      b.adjust_blocks false
    end

    @sf.stubs(:source).returns("things.map {|th|th+1}\n")
    @sf.tokenize!
    BlockFormatter.format( @sf )
    assert_equal @sf.lines[0].joined_tokens, "things.map {|th|th+1}\n"

    BlockFormatter.configure do |b|
      b.adjust_blocks true
    end
  end

  def test_should_use_correct_number_of_correct_characters
    BlockFormatter.configure do |b|
      b.padding_character "t"
      b.padding_character_count 2
    end

    @sf.stubs(:source).returns("things.map {|th|th+1}\n")
    @sf.tokenize!
    BlockFormatter.format( @sf )
    assert_equal @sf.lines[0].joined_tokens, "things.map {tt|th|th+1tt}\n"

    BlockFormatter.configure do |b|
      b.padding_character " "
      b.padding_character_count 1
    end
  end
end
