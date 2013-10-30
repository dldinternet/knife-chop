module Eden
  module OperatorTokenizer
    def tokenize_equals_operators
      advance
      default_expr_state_transition!
      case cchar
      when '>'
        advance and capture_token(:hash_rocket)
      when "~"
        advance and capture_token(:matches)
      when '='
        advance
        if cchar == '='
          advance and capture_token(:identity_equality)
        else
          capture_token(:equality)
        end
      else
        capture_token(:equals)
      end
    end

    def tokenize_bang_operators
      @expr_state = :beg
      advance
      case cchar
      when '='
        advance and capture_token(:not_equals)
      when '~'
        advance and capture_token(:not_matches)
      else
        capture_token(:logical_not)
      end
    end

    def tokenize_plus_operators
      advance
      case cchar
      when '='
        @expr_state = :beg
        advance and capture_token(:plus_equals)
      when '@'
        @expr_state = :arg if [:fname, :dot].include?(@expr_state)
        advance and capture_token(:plus_at)
      else
        @expr_state = :beg
        capture_token(:plus)
      end
    end

    def tokenize_minus_operators
      advance
      case cchar
      when '='
        @expr_state = :beg
        advance and capture_token(:minus_equals)
      when '@'
        @expr_state = :arg if [:fname, :dot].include?(@expr_state)
        advance and capture_token(:minus_at)
      else
        @expr_state = :beg
        capture_token(:minus)
      end
    end

    def tokenize_multiply_operators
      advance
      case cchar
      when '*'
        @expr_state = :beg
        advance
        if cchar == '='
          advance and capture_token(:exponent_equals)
        else
          capture_token(:exponent)
        end
      when '='
        @expr_state = :beg
        advance and capture_token(:multiply_equals)
      else
        # TODO: Add logic to disamiguate between splat and multiply
        default_expr_state_transition!
        capture_token(:multiply)
      end
    end

    # Tokenizes operators using the \ character, after tokenize_potential_regex
    # has decided that it's not the start of a regex.
    def tokenize_divide_operators
      advance
      if cchar == '='
        @expr_state = :beg
        advance and capture_token(:divide_equals)
      else
        default_expr_state_transition!
        capture_token(:divide)
      end
    end

    def tokenize_lt_operators
      advance 
      default_expr_state_transition!
      case cchar
      when '<'
        advance

        if ![:end, :dot, :end_arg, :class].include?(@expr_state) && cchar != ' '
          token = tokenize_heredoc_delimiter
          return token if token
        end

        if cchar == '='
          @expr_state = :beg
          advance and capture_token(:left_shift_equals)
        else
          capture_token(:left_shift)
        end
      when '='
        advance
        if cchar == '>'
          advance and capture_token(:sort_operator)
        else
          capture_token(:lte)
        end
      else
        capture_token(:lt)
      end
    end

    def tokenize_gt_operators
      advance
      default_expr_state_transition!
      case cchar
      when '>'
        advance
        if cchar == '='
          advance and capture_token(:right_shift_equals)
        else
          capture_token(:right_shift)
        end
      when '='
        advance and capture_token(:gte)
      else
        capture_token(:gt)
      end
    end

    def tokenize_pipe_operators
      advance
      case cchar
      when '|'
        advance
        @expr_state = :beg
        if cchar == '='
          advance and capture_token(:logical_or_equals)
        else
          capture_token(:logical_or)
        end
      when '='
        @expr_state = :beg
        advance and capture_token(:bitwise_or_equals)
      else
        default_expr_state_transition!
        capture_token(:bitwise_or)
      end
    end

    def tokenize_ampersand_operators
      advance
      case cchar
      when '&'
        advance
        @expr_state = :beg
        if cchar == '='
          advance and capture_token(:logical_and_equals)
        else
          capture_token(:logical_and)
        end
      when '='
        @expr_state = :beg
        advance and capture_token(:bitwise_and_equals)
      else
        default_expr_state_transition!
        capture_token(:bitwise_and)
      end
    end

    def tokenize_caret_operators
      advance
      if cchar == "="
        @expr_state = :beg
        advance and capture_token(:caret_equals)
      else
        default_expr_state_transition!
        capture_token(:caret)
      end
    end

    def tokenize_modulo_operators
      advance
      if cchar == "="
        @expr_state = :beg
        advance and capture_token(:modulo_equals)
      else
        default_expr_state_transition!
        capture_token(:modulo)
      end
    end

  end
end
