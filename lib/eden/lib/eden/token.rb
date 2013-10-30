module Eden
  class Token
    attr_accessor :type, :content

    BINARY_OPERATORS = [:matches, :identity_equality, :equality,
                        :not_equals, :not_matches, :plus_equals, :plus,
                        :plus_at, :plus, :minus_equals, :minus_at, :minus,
                        :exponent_equals, :exponent, :multiply_equals, :multiply,
                        :divide, :divide_equals,
                        :left_shift_equals, :left_shift, :lte, :lt,
                        :right_shift_equals, :right_shift, :gte, :gt,
                        :sort_operator,
                        :logical_or_equals, :logical_or,
                        :bitwise_or_equals, :bitwise_or,
                        :logical_and_equals, :logical_and,
                        :bitwise_and_equals, :bitwise_and]

    UNARY_OPERATORS = [:plus, :minus, :multiply, :logical_not, :tilde]
                 
    KEYWORDS = [:__LINE__, :__ENCODING__, :__FILE__, :BEGIN,   
                :END, :alias, :and, :begin, :break, :case,
                :class, :def, :defined?, :do, :else, :elsif,
                :end, :ensure, :false, :for, :if, :in,
                :module, :next, :nil, :not, :or, :redo,
                :rescue, :retry, :return, :self, :super,
                :then, :true, :undef, :unless, :until, 
                :when, :while, :yield]

    def initialize( type, content )
      @type = type
      @content = content
    end

    def inspect
      if @content.nil? || @content == "\n"
        @type.to_s
      else
        @type.to_s + "- \"" + @content + "\""
      end
    end

    def operator?
       binary_operator? || unary_operator?
    end

    def unary_operator?
      UNARY_OPERATORS.include?( type )
    end

    def binary_operator?
      BINARY_OPERATORS.include?( type )
    end

    def keyword?
      KEYWORDS.include?( type )
    end

    def is?( token_type )
      @type == token_type
    end
  end
end
