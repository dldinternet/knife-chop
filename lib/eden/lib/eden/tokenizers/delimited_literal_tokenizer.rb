module Eden
  module DelimitedLiteralTokenizer
    def tokenize_delimited_literal
      advance # Pass the %

      if( /[^A-Za-z0-9]/.match( cchar ) )
        def_char = 'Q'
        @state = :double_q_string
      elsif( /[qQswWrx]/.match( cchar) )
        def_char = cchar
        @state = infer_delimited_literal_type  
        advance
      else
        raise "Invalid delimiter character"
      end

      case def_char
      when 'r', 'Q', 'W', 'x'
        token = tokenize_expanded_string( cchar )
      when 's', 'q', 'w'
        token = tokenize_non_expanded_string( cchar )
      end

      return token
    end

    def infer_delimited_literal_type
      case cchar
        when 's' then :symbol
        when 'w', 'W' then :array_literal
        when 'q' then :single_q_string
        when 'Q' then :double_q_string
        when 'r' then :regex
        when 'x' then :backquote_string
      end
    end
  end
end
