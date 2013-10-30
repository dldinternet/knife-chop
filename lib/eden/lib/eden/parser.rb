module Eden
  # Parser
  #
  # A base class providing configuration behaviour for Eden's source code
  # parsers.
  class Parser
    class << self
      attr_accessor :options
    end

    def self.configure
      yield self
    end

    def self.parse( source_file )
      raise "Parse function not implmented."
    end

    def self.method_missing(name, *args, &block)
      self.options ||= {}
      self.options[name.to_sym] = *args[0]
    end
  end
end

