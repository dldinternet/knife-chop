require 'eden/tokenizers/basic_tokenizer'
require 'eden/tokenizers/delimited_literal_tokenizer'
require 'eden/tokenizers/number_tokenizer'
require 'eden/tokenizers/operator_tokenizer'
require 'eden/tokenizers/regex_tokenizer'
require 'eden/tokenizers/string_tokenizer'


module Eden
  class Tokenizer
    include BasicTokenizer
    include DelimitedLiteralTokenizer
    include NumberTokenizer
    include OperatorTokenizer
    include RegexTokenizer
    include StringTokenizer
    
    def initialize( source )
      @sf = source
      @interpolating = [] # Stack for state when interpolating into strings
      @delimiters = [] # Stack for delimiters which we need to keep when interpolating
    end
      
    def tokenize!
      @i = 0 # Current position in the source buffer
      @ln = 1 # Line Number
      @cp = 0 # Current Character in the line
      @thunk_st = 0
      @thunk_end = -1 # Start/end of the current token
      @current_line = Line.new( @ln )
      @length = @sf.source.length
      @expr_state = :beg # Same as lex_state variable in parse.c in Ruby source
      default_state_transitions!

      until( @i >= @length )
        case( @state )
        when :newline
          advance
          @expr_state = :beg
          @current_line.tokens << capture_token( :newline )
          @current_line.tokens.flatten!
          @sf.lines << @current_line
          @ln += 1
          @current_line = Line.new( @ln )

          if @heredoc_delimiter
            @current_line.tokens << tokenize_heredoc_body
          end
        when :whitespace
          @current_line.tokens << tokenize_whitespace
        when :identifier # keyword / name / etc
          @current_line.tokens << tokenize_identifier
        when :instancevar
          @current_line.tokens << tokenize_instancevar
        when :classvar
          @current_line.tokens << tokenize_classvar
        when :globalvar
          @current_line.tokens << tokenize_globalvar
        when :delimited_literal
          @current_line.tokens << tokenize_delimited_literal
        when :lparen, :lsquare, :lcurly
          @expr_state = :beg
          @current_line.tokens << tokenize_single_character
        when :comma
          @expr_state = :beg
          @current_line.tokens << tokenize_single_character
        when :rsquare, :lcurly, :rparen
          @expr_state = :end
          @current_line.tokens << tokenize_single_character
        when :rcurly
          @current_line.tokens << tokenize_rcurly
        when :tilde
          default_expr_state_transition!
          @current_line.tokens << tokenize_single_character
        when :at, :semicolon, :backslash
          @current_line.tokens << tokenize_single_character
        when :question_mark
          @current_line.tokens << tokenize_question_mark
        when :colon
          @current_line.tokens << tokenize_colon
        when :period
          @current_line.tokens << tokenize_period
        when :plus
          @current_line.tokens << tokenize_plus_operators
        when :minus
          @current_line.tokens << tokenize_minus_operators
        when :equals
          @current_line.tokens << tokenize_equals_operators
        when :multiply
          @current_line.tokens << tokenize_multiply_operators
        when :divide
          @current_line.tokens << tokenize_potential_regex
        when :lt
          @current_line.tokens << tokenize_lt_operators
        when :gt
          @current_line.tokens << tokenize_gt_operators
        when :pipe
          @current_line.tokens << tokenize_pipe_operators
        when :ampersand
          @current_line.tokens << tokenize_ampersand_operators
        when :modulo
          @current_line.tokens << tokenize_modulo_operators
        when :caret
          @current_line.tokens << tokenize_caret_operators
        when :bang
          @current_line.tokens << tokenize_bang_operators
        when :comment
          @current_line.tokens << tokenize_comment
        when :single_q_string 
          @current_line.tokens << tokenize_single_quote_string
        when :double_q_string
          @current_line.tokens << tokenize_double_quote_string
        when :backquote_string
          @current_line.tokens << tokenize_backquote_string
        when :symbol
          @current_line.tokens << tokenize_symbol
        when :dec_literal
          @current_line.tokens << tokenize_decimal_literal
        when :bin_literal, :oct_literal, :hex_literal
          @current_line.tokens << tokenize_integer_literal
        end
      end
      @sf.lines << @current_line.flatten!
    end

    private
    
    def thunk
      @sf.source[[@thunk_st, @length-1].min..[@thunk_end, @length-1].min]
    end

    def default_state_transitions!
      case( cchar )
      when nil  then @state = :eof
      when ' '  then @state = :whitespace
      when "\t" then @state = :whitespace
      when "\n" then @state = :newline
      when '"'  then @state = :double_q_string
      when '\'' then @state = :single_q_string
      when '`'  then @state = :backquote_string
      when '$'  then @state = :globalvar
      when '@'
        if peek_ahead_for( /@/ )
          @state = :classvar
        elsif peek_ahead_for( /[A-Za-z_]/ )
          @state = :instancevar
        else 
          @state = :at
        end
      when '/'  then @state = :divide
      when '#'  then @state = :comment
      when ','  then @state = :comma
      when '.'  then @state = :period
      when '&'  then @state = :ampersand
      when '!'  then @state = :bang
      when '~'  then @state = :tilde
      when '^'  then @state = :caret
      when '|'  then @state = :pipe
      when '>'  then @state = :gt
      when '<'  then @state = :lt
      when '?'  then @state = :question_mark
      when ';'  then @state = :semicolon
      when '='  then @state = :equals
      when '\\'  then @state = :backslash
      when '%'
        if @expr_state == :beg && !peek_ahead_for(/ /)
          @state = :delimited_literal
        else
          @state = :modulo
        end
      when '*'  then @state = :multiply
      when '('  then @state = :lparen
      when ')'  then @state = :rparen
      when '{'
        @interpolating << nil
        @state = :lcurly
      when '}'  then @state = :rcurly
      when '['  then @state = :lsquare
      when ']'  then @state = :rsquare
      when ':'
        if peek_ahead_for(/[: ]/)
          @state = :colon
        else
          @state = :symbol
        end
      when 'a'..'z', 'A'..'Z', '_'
        @state = :identifier
      when '0'
        @expr_state = :end
        if peek_ahead_for(/[xX]/)
          @state = :hex_literal 
        elsif peek_ahead_for(/[bB]/)
          @state = :bin_literal 
        elsif peek_ahead_for(/[_oO0-7]/)
          @state = :oct_literal
        elsif peek_ahead_for(/[89]/)
          puts "Illegal Octal Digit"
        elsif peek_ahead_for(/[dD]/)
          @state = :dec_literal
        else
          @state = :dec_literal
        end
      when '1'..'9'
        @state = :dec_literal
      when '+', '-'
        if peek_ahead_for( /[0-9]/ )
          @state = :dec_literal
        else
          @state = ( cchar == '+' ? :plus : :minus )
        end
      end
    end

    # Manages the expression state to match the state machine in parse.c
    def default_expr_state_transition!
      if @expr_state == :fname || @expr_state == :dot
        @expr_state = :arg
      else
        @expr_state = :beg
      end
    end

    # Helper functions for expression state, from parse.c:9334
    def is_arg
      [:arg, :cmd_arg].include?( @expr_state )
    end

    def is_beg
      [:beg, :mid, :class].include?( @expr_state )
    end

    # Returns the current character
    def cchar
      @sf.source[@i..@i]
    end

    # Advance the current position in the source file
    def advance( num=1 )
      @thunk_end += num; @i += num
    end

    # Resets the thunk to start at the current character
    def reset_thunk!
      @thunk_st = @i
      @thunk_end = @i - 1
    end

    def peek_ahead_for( regex )
      @sf.source[@i+1..@i+1] && !!regex.match( @sf.source[@i+1..@i+1] )
    end

    def capture_token( type )
      token = Token.new( type, thunk )
      reset_thunk!
      default_state_transitions!
      return token
    end
  end
end
