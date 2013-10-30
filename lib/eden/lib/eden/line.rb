module Eden
  class Line
    attr_accessor :line_no, :tokens

    def initialize( line_no )
      @line_no = line_no
      @tokens = []
      @warnings = []
    end

    def flatten!
      @tokens.flatten!
      self
    end

    def last_token_is_space?
      @tokens[-1].type == :whitespace
    end

    def joined_tokens
      tokens.map { |t| t.content }.join('')
    end

    def previous_token( token )
      token_index = tokens.index( token )
      return nil if token_index.nil? || token_index == 0
      return tokens[token_index-1]
    end

    def previous_non_whitespace_token( token )
      token_index = tokens.index( token )
      return nil if token_index.nil? || token_index == 0
      token_index -= 1
      while( token_index != 0 )
        return tokens[token_index] if tokens[token_index].type != :whitespace
        token_index -= 1
      end
      return nil
    end

    def next_token( token )
      token_index = tokens.index( token )
      return nil if token_index.nil? || token_index == tokens.length
      return tokens[token_index+1]
    end

    def insert_token_after( token, new_token )
      token_index = tokens.index( token )
      if token_index.nil?
        tokens.push( new_token )
      else
        tokens.insert( token_index+1, new_token )
      end
    end
    
    def insert_token_before( token, new_token )
      token_index = tokens.index( token )
      if token_index.nil?
        tokens.unshift( new_token )
      else
        tokens.insert( token_index, new_token )
      end
    end
  end
end
