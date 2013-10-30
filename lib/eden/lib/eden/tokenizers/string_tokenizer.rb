module Eden
  module StringTokenizer
    def tokenize_single_quote_string
      tokenize_non_expanded_string("'")
    end

    # If a block is given, it gets run after the final delimiter is detected. The
    # primary purpose for this is to allow the capture of regex modifiers
    def tokenize_non_expanded_string( start_delimiter )
      delimiter_depth = 0
      matched_delimiter = is_matched_delimiter?( start_delimiter )
      end_delimiter = find_matching_delimiter( start_delimiter )

      advance # Pass the opening delimiter

      until((cchar == end_delimiter && delimiter_depth == 0) || @i >= @length)

        if matched_delimiter
          delimiter_depth += 1 if cchar == start_delimiter
          delimiter_depth -= 1 if cchar == end_delimiter
        end

        if cchar == '\\'
          advance(2) # Pass the escaped character
        else
          advance
        end
      end
      advance # Pass the closing quote

      if @state == :regex
        advance if ['i', 'm'].include?( cchar )
      end

      @expr_state = :end
      capture_token( @state )
    end

    def tokenize_backquote_string
      tokenize_expanded_string( '`' )
    end

    def tokenize_double_quote_string( in_string_already = false )
      tokenize_expanded_string('"', in_string_already)
    end

    def tokenize_expanded_string( start_delimiter, in_string_already = false )
      saved_state = @state
      tokens = []
      end_delimiter = find_matching_delimiter( start_delimiter )
      advance unless in_string_already # Pass the opening backquote
      until( cchar == end_delimiter || @i >= @length )
        if cchar == '\\'
          advance(2) # Pass the escaped character
        elsif cchar == '#'
          advance # include the # character in the string
          case cchar
          when '{'
            @interpolating.push( @state )
            @delimiters.push( start_delimiter )
            tokens << Token.new( @state, thunk )
            reset_thunk!
            @state = :lcurly
            tokens << tokenize_single_character
            return tokens
          when '@'
            tokens << capture_token( @state )
            if peek_ahead_for('@')
              tokens << tokenize_classvar
            else
              tokens << tokenize_instancevar
            end
            @state = saved_state
          when '$'
            tokens << capture_token( @state )
            tokens << tokenize_globalvar
            @state = saved_state
          end
        else
          advance
        end
      end
      advance # Pass the closing delimiter
      if @state == :regex
        advance if ['i', 'm'].include?( cchar )
      end
      @expr_state = :end
      tokens << capture_token( @state )
      return tokens
    end
  
    # Called from tokenize_lt_operators when it identifies that 
    # << is a heredoc delimiter. Expects that '<<' will already
    # be included in the current thunk.
    def tokenize_heredoc_delimiter
      offset = 2
      if cchar == '-'
        advance
        offset = 3
      end

      if cchar =~ /[A-Za-z_]/
        advance
        advance until /[A-Za-z0-9_]/.match( cchar ).nil?
      elsif /['"`]/.match(cchar)
        advance_through_quoted_delimiter(cchar)
      else
        return nil
      end
      @heredoc_delimiter = thunk[offset..-1]
      capture_token( :heredoc_delimiter )
    end

    def tokenize_heredoc_body
      if @heredoc_delimiter
        advance until (@sf.source[@i, @heredoc_delimiter.length ] == @heredoc_delimiter && 
          @sf.source[@i, @heredoc_delimiter.length+1 ] == @heredoc_delimiter + "\n" ||
          @sf.source[@i, @heredoc_delimiter.length+2 ] == @heredoc_delimiter + "\r\n") ||
          @i >= @length
      end
      @heredoc_delimiter.length.times { advance }
      @heredoc_delimiter = nil
      capture_token( :heredoc_body )
    end

    private
    # Returns the matching delimiter for the 4 "paired" delimiters
    def find_matching_delimiter( start_delimiter )
      case start_delimiter
      when '{' then '}'
      when '(' then ')'
      when '[' then ']'
      when '<' then '>'
      else
        start_delimiter
      end
    end

    def is_matched_delimiter?( cchar )
      !! /[{\(\[<]/.match(cchar)
    end

    def advance_through_quoted_delimiter( delimiter )
      advance
      advance until cchar == delimiter
      advance
    end
  end
end
