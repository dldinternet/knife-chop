require 'eden/source'

module Eden
  class SourceFile < Source

    def initialize( file_name )
      @file_name = file_name
      load!
      super(@source)
    end

    def rewrite!
      File.open(@file_name, 'w') do |f|
        each_line do |l|
          f.write l.joined_tokens
        end
      end
    end

    private

    def load!
      file = File.open( @file_name, "r" )
      @source = file.read
      file.close()
    end

  end
end
