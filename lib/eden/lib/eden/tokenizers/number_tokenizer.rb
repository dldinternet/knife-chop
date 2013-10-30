module Eden
  module NumberTokenizer

    # Tokenize a non-decimal integer literal - e.g. Ox4F2E, 0b1101
    def tokenize_integer_literal
      @expr_state = :end
      if peek_ahead_for(/[_oObBxX]/)
        advance(2) # Pass 0x / 0b / 0O
      else
        advance # Pass 0 for Octal digits
      end
      pattern = {:bin_literal => /[01]/,
                 :oct_literal => /[0-7]/,
                 :hex_literal => /[0-9a-fA-F]/}[@state]
      advance until( pattern.match( cchar ).nil? )
      capture_token( @state )
    end

    def tokenize_decimal_literal
      @expr_state = :end
      # Capture the sign
      advance if cchar == '+' || cchar == '-'

      # Handle a lone zero
      if cchar == '0' && !peek_ahead_for(/[dD]/)
        advance
        return capture_token( :dec_literal )
      end

      # Handle 0d1234 digits
      advance(2) if cchar == '0' && peek_ahead_for(/[dD]/)

      until( /[0-9.eE]/.match( cchar ).nil? )
        case cchar
        when '.'
          return tokenize_float_literal
        when 'e', 'E'
          return tokenize_exponent_literal
        when '0'..'9'
          advance
        else
        end
      end
      capture_token( :dec_literal )
    end

    # Tokenize a literal with an exponent - e.g. 3.4E+22
    def tokenize_exponent_literal
      advance # Pass the e/E
      advance if cchar == '+' or cchar == '-'
      advance until( /[0-9]/.match( cchar ).nil? )
      capture_token( :exp_literal )
    end

    # Tokenize a float literal - e.g. 2.0, 2.1101
    def tokenize_float_literal
      advance # Pass the .

      until( /[0-9eE]/.match( cchar ).nil? )
        if cchar == 'e' || cchar == 'E'
          return tokenize_exponent_literal
        end
        advance
      end
      capture_token( :float_literal )
    end
  end
end
