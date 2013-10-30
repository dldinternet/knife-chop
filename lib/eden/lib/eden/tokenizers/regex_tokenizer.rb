module Eden
  module RegexTokenizer
    def tokenize_potential_regex

      if @expr_state == :beg || @expr_state == :mid || @expr_state == :class
        return tokenize_regex
      end

      if peek_ahead_for(/=/)
        return tokenize_divide_operators
      end

      if (@expr_state == :arg || @expr == :cmd_arg) && @line.last_token_is_space?
        return tokenize_regex
      end

      return tokenize_divide_operators
    end

    def tokenize_regex
      advance # Consume the leading /
      while true
        if cchar == '/'
          advance
          # Capture the regex option
          advance if cchar =~ /i|o|m|x|n|e|u|s/
          return capture_token(:regex)
        end
        if cchar == nil #end of file
          raise "Unclosed Regex found"
        end
        advance if cchar == '\\'
        advance
      end
    end
  end
end
