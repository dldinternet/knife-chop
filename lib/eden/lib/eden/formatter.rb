module Eden
  # Formatter
  # 
  # A base class providing configuration behaviour for Eden's source code
  # formatters.
  class Formatter
    class << self
      attr_accessor :options
      attr_reader   :formatters
      attr_reader   :source_files
    end

    def self.configure
      yield self
    end

    def self.init(options={})

      @source_files = []

      # Automatically load all the formatters
      @formatters = []

      # Load all the formatters
      Dir.glob(["#{File.dirname(__FILE__)}/formatters/*.rb"] ) do |file|
        require "#{file}"
        const_name = camelize( File.basename(file, ".rb"))
        @formatters << Object.const_get( const_name )
      end

      # Setup defaults
      require 'eden/defaults'

      # Load formatting customizations
      if File.exists?("./config/eden.rb")
        require './config/eden.rb'
      end

    end

    def self.format( source_file )
      sf = Eden::SourceFile.new( source_file )
      @source_files << sf
      sf.source = format_source(sf.source)
      @formatters.each do |formatter|
        formatter.format( sf )
      end
      sf.rewrite!
    end

    def self.method_missing(name, *args, &block)
      self.options ||= {}
      self.options[name.to_sym] = args[0]
    end

    # --------------------------------------------------------------------------------------------------------------------
    def self.format_source(source)
      self.init unless @formatters
      sf = nil
      begin
        sf = Eden::Source.new( source )
        sf.tokenize!
        @formatters.each do |formatter|
          formatter.format( sf )
        end
      rescue => e
        puts e
        sf.lines.each { |l| puts l.joined_tokens }
      end
      sf.source
    end

    # --------------------------------------------------------------------------------------------------------------------
    # Displays a source file on STDOUT using ANSI escape codes for
    # syntax highlighting
    def self.colorize( sf )
      sf.lines.each do |line|
        print "[#{line.line_no}] "
        line.tokens.flatten.each do |t|
          case t.type
            when :regex
              print "\033[32m"
              print t.content
              print "\033[0m"
            when :double_q_string, :single_q_string
              print "\033[0;36m" + t.content + "\033[0m"
            when :symbol
              print "\033[31m" + t.content + "\033[0m"
            when :instancevar
              print "\033[1;34m" + t.content + "\033[0m"
            when :comment
              print "\033[1;30m" + t.content + "\033[0m"
            else
              if t.keyword?
                print "\033[33m" + t.content + "\033[0m"
              else
                print t.content
              end
          end
        end
      end
    end

    # --------------------------------------------------------------------------------------------------------------------
    def self.debug( source_file )
      source_file.lines.each do |l|
        puts l.tokens.inspect
      end
    end

    private

    # --------------------------------------------------------------------------------------------------------------------
    # Taken from ActiveSupport
    def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end


  end
end

