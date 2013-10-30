# BlockFormatter
#
# Formats inline blocks ( including string interpolations ) by formatting the correct spacing
# around the content of the block.
#
# Options:
#
# - adjust_blocks - (true|false) Make any changes at all to blocks?
# - padding_character - (string) character to use to space between the content of the block and its braces
# - padding_character_count - (integer) number of spaces to use after/before each brace. Can be 0.

class BlockFormatter < Eden::Formatter
  def self.format( source_file )
    return unless options[:adjust_blocks]

    space = (options[:padding_character] * options[:padding_character_count])
    use_space = space.length != 0
    
    source_file.each_line do |line|
      line.tokens.each do |token|
        if token.is?( :lcurly )
          next_token = line.next_token( token )
          if next_token && next_token.content != space
            if next_token.is?(:whitespace)
              next_token.content == space
            else
              new_space_token = Eden::Token.new(:whitespace, space)
              line.insert_token_after(token, new_space_token)
            end
          end
        elsif token.is?( :rcurly )
          prev_token = line.previous_token( token )
          if prev_token && prev_token.content != space
            if prev_token.is?( :whitespace )
              prev_token.content == space
            else
              new_space_token = Eden::Token.new(:whitespace, space)
              line.insert_token_before(token, new_space_token)
            end
          end
        end
      end
    end
  end
end
