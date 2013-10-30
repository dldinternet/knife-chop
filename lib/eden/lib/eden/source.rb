module Eden
  class Source
    attr_accessor :source, :lines

    def initialize( source )
      @source = source
      @lines = []
    end

    def tokenize!
      tokenizer = Tokenizer.new( self )
      tokenizer.tokenize!
    end

    def each_line
      @lines.each { |l| yield l }
    end

  end
end
