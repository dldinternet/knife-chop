module Eden
  module BasicTokenizer
    def tokenize_single_character
      @thunk_end += 1
      token = Token.new(@state, thunk)
      @i += 1
      reset_thunk!
      default_state_transitions!
      return token
    end

    def tokenize_period
      advance
      if cchar == '.'
        advance
        @expr_state = :beg
        return (advance and capture_token( :range_inc )) if cchar == '.'
        capture_token( :range_exc )
      else
        @expr_state = :dot
        capture_token( :period )
      end
    end
    
    def tokenize_rcurly
      @thunk_end += 1
      old_state = @interpolating.pop
      old_start_delimiter = @delimiters.pop
      tokens = []
      if old_state
        tokens << Token.new(@state, thunk)
        @i += 1
        reset_thunk!
        @state = old_state
        tokens << tokenize_expanded_string( old_start_delimiter, true)
      else
        tokens << Token.new(@state, thunk)
        @i += 1
        reset_thunk!
      end
      default_state_transitions!
      return tokens
    end

    # tokenizes operators beginning with a colon
    def tokenize_colon
      advance
      if cchar == ':'
        advance
        if is_beg || (is_arg && @line.last_token_is_space?)
          @expr_state = :beg
        else
          @expr_state = :dot
        end
        return capture_token( :scope_res )
      else
        @expr_state = :beg
        return capture_token(:colon)
      end
    end

    # tokenizes question mark / character literals
    def tokenize_question_mark
      advance
      if @expr_state == :end || @expr_state == :endarg
        @expr_state = :beg
        return capture_token(:question_mark)
      end

      if (cchar != ' ' && cchar != "\t") && @i < @length
        advance until cchar == ' ' || cchar == "\t" ||
          cchar == "\r" || cchar == "\n" || @i > @length
        return capture_token(:character_literal)
      end

      capture_token(:question_mark)
    end

    def tokenize_identifier
      @expr_state = :end
      advance until( /[A-Za-z0-9_]/.match( cchar ).nil? )
      translate_keyword_tokens(capture_token( @state ))
    end

    def tokenize_whitespace
      advance until( cchar != ' ' && cchar != "\t" )
      capture_token( :whitespace )
    end

    def tokenize_comment
      advance until( cchar == "\n" || cchar.nil?)
      capture_token( :comment )
    end

    def tokenize_instancevar
      @expr_state = :end
      advance # Pass the @ symbol
      advance until( /[a-z0-9_]/.match( cchar ).nil? )
      capture_token( :instancevar )
    end

    def tokenize_classvar
      @expr_state = :end
      advance(2) # Pass the @@ symbol
      advance until( /[a-z0-9_]/.match( cchar ).nil? )
      capture_token( :classvar )
    end

    def tokenize_symbol
      @expr_state = :end
      advance # Pass the :
      case cchar
      when '"'  then return tokenize_double_quote_string
      when '\'' then return tokenize_single_quote_string
      end
      if /^(\^|&|\||<=>|==|===|!~|=~|>>|>=|<<|<=|>|<|\+|\-|\*\*|\/|%|\*|~|\+@|-@|\[\]|\[\]=)/x.match(@sf.source[@i..-1])
        advance($1.length)
        return capture_token(:symbol)
      end
      advance while( /[A-Za-z0-9_!=\?]/.match(cchar) )
      capture_token( :symbol )
    end

    def tokenize_globalvar
      @expr_state = :end
      advance # Pass the $
      if /[!@_\.&~0-9=\/\\\*$\?:'`]/.match( cchar )
        advance and capture_token( :globalvar )
      elsif /[A-Za-z0-9_]/.match( cchar )
        advance while /[A-Za-z0-9_]/.match( cchar )
        capture_token( :globalvar )
      else
        raise "Invalid Global Variable Name"
      end
    end

    # Takes an identifier token, and tranforms its type to
    # match Ruby keywords where the identifier is actually a keyword.
    # Reserved words are defined in S.8.5.1 of the Ruby spec.
    def translate_keyword_tokens( token )
      keywords = ["__LINE__", "__ENCODING__", "__FILE__", "BEGIN",   
                  "END", "alias", "and", "begin", "break", "case",
                  "class", "def", "defined?", "do", "else", "elsif",
                  "end", "ensure", "false", "for", "if", "in",
                  "module", "next", "nil", "not", "or", "redo",
                  "rescue", "retry", "return", "self", "super",
                  "then", "true", "undef", "unless", "until", 
                  "when", "while", "yield"]
      if keywords.include?( token.content )
        token.type = token.content.downcase.to_sym
        # Change the state if we match a keyword
        @expr_state = :beg
      end
      
      # A couple of exceptions      
      if token.content == "BEGIN"
        token.type = :begin_global 
        @expr_state = :beg
      elsif token.content == "END"
        token.type = :end_global 
        @expr_state = :beg
      end
      
      token
    end
  end
end
