require "rubygems"
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
require 'logging'

class Chef
  class Knife
    module ChopLogging
      attr :logger
      attr_reader :args
      attr_reader :step
      attr_reader :TODO

      class ::Logging::ColorScheme
        def scheme
          @scheme
        end
      end

      class ::Logging::Logger
        class << self
          def define_log_methods( logger )
            ::Logging::LEVELS.each do |name,num|
              code =  "undef :#{name}  if method_defined? :#{name}\n"
              code << "undef :#{name}? if method_defined? :#{name}?\n"

              if logger.level > num
                code << <<-CODE
                  def #{name}?( ) false end
                  def #{name}( data = nil, trace = false ) false end
                CODE
              else
                code << <<-CODE
                  def #{name}?( ) true end
                  def #{name}( data = nil, trace = nil )
                    caller = Kernel.caller[3]
                    num = #{num}
                    unless caller.match(%r(/knife-chop/))
                      num -= 1
                    end
                    if num >= #{logger.level}
                      data = yield if block_given?
                      #log_event(::Logging::LogEvent.new(@name, num, caller, true))
                      log_event(::Logging::LogEvent.new(@name, num, data, trace.nil? ? @trace : trace))
                    end
                    true
                  end
                CODE
              end

              logger._meta_eval(code, __FILE__, __LINE__)
            end
            logger
          end
        end

        def logEvent(evt)
          log_event evt
        end
      end

      class ::Logging::Layouts::Pattern
        # Arguments to sprintf keyed to directive letters
        verbose, $VERBOSE = $VERBOSE, nil
        DIRECTIVE_TABLE = {
            'c' => 'event.logger'.freeze,
            'd' => 'format_date(event.time)'.freeze,
            'F' => 'event.file'.freeze,
            'l' => '::Logging::LNAMES[event.level]'.freeze,
            'L' => 'event.line'.freeze,
            'm' => 'format_obj(event.data)'.freeze,
            'M' => 'event.method'.freeze,
            'p' => 'Process.pid'.freeze,
            'r' => 'Integer((event.time-@created_at)*1000).to_s'.freeze,
            't' => 'Thread.current.object_id.to_s'.freeze,
            'T' => 'Thread.current[:name]'.freeze,
            'C' => 'event.file != "" ? "(\e[38;5;25m#{event.file}::#{event.line}\e[0m)" : ""',
            '%' => :placeholder
        }.freeze

        # Human name aliases for directives - used for colorization of tokens
        COLOR_ALIAS_TABLE = {
            'c' => :logger,
            'd' => :date,
            'm' => :message,
            'p' => :pid,
            'r' => :time,
            'T' => :thread,
            't' => :thread_id,
            'F' => :file,
            'L' => :line,
            'M' => :method,
            'X' => :mdc,
            'x' => :ndc,
            'C' => :file_line,
        }.freeze

      ensure
        $VERBOSE = verbose
      end

      # --------------------------------------------------------------------------------
      def logTodo(msg)

        # Regular expression used to parse out caller information
        #
        # * $1 == filename
        # * $2 == line number
        # * $3 == method name (might be nil)
        caller_rgxp = %r/([-\.\/\(\)\w]+):(\d+)(?::in `(\w+)')?/o
        #CALLER_INDEX = 2
        caller_index = ((defined? JRUBY_VERSION and JRUBY_VERSION[%r/^1.6/]) or (defined? RUBY_ENGINE and RUBY_ENGINE[%r/^rbx/i])) ? 0 : 0
        stack = Kernel.caller
        return if stack.nil?

        match = caller_rgxp.match(stack[caller_index])
        file = match[1]
        line = Integer(match[2])
        modl = match[3] unless match[3].nil?

        unless @TODO["#{file}::#{line}"]
          le = ::Logging::LogEvent.new(@logger, ::Logging::LEVELS['todo'], msg, false)
          @logger.logEvent(le)
          @TODO["#{file}::#{line}"] = true
        end
      end

      # -----------------------------------------------------------------------------
      def logStep(msg)
        if logger = getLogger(@args,'logStep')
          logger.step "Resource #{@step+=1}: #{msg} ..."
        end
      end

      # -----------------------------------------------------------------------------
      # Set up logger

      class FakeLogger
        def method_missing(m, *args, &block)
          puts args[0]
        end
      end

      def setLogger(logger)
        @logger = logger
      end

      def getLogger(args,from='',alogger=nil)
        logger = alogger || @logger
        unless logger
          unless from==''
            from = "#{from} - "
          end
          @step = 0
          if args
            if args.key?(:log_file) and args[:log_file]
              args[:log_path] = File.dirname(args[:log_file])
            elsif args[:my_name]
              if args[:log_path]
                args[:log_file] = "#{args[:log_path]}/#{args[:my_name]}.log"
              else
                args[:log_file] = "/tmp/#{args[:my_name]}.log"
              end
            end

            begin
              ::Logging.init :trace, :debug, :info, :step, :warn, :error, :fatal, :todo unless defined? ::Logging::MAX_LEVEL_LENGTH
              if args[:origins] and args[:origins][:log_level]
                if (::Logging::LEVELS[args[:log_level].to_s] and ::Logging::LEVELS[args[:log_level].to_s] < 2)
                  #puts "#{args[:log_level].to_s} = #{::Logging::LEVELS[args[:log_level].to_s]}".light_yellow
                  puts "#{args[:origins][:log_level]} says #{args[:log_level]}".light_yellow
                else
                  from = ''
                end
              end
              l_opts = args[:log_opts].call(::Logging::MAX_LEVEL_LENGTH) || {
                  :pattern      => "#{from}%d %#{::Logging::MAX_LEVEL_LENGTH}l: %m\n",
                  :date_pattern => '%Y-%m-%d %H:%M:%S',
              }
              logger = ::Logging.logger( STDOUT, l_opts)
              l_opts = args[:log_opts].call(::Logging::MAX_LEVEL_LENGTH) || {
                  :pattern      => "#{from}%d %#{::Logging::MAX_LEVEL_LENGTH}l: %m %C\n",
                  :date_pattern => '%Y-%m-%d %H:%M:%S',
              }
              layout = ::Logging::Layouts::Pattern.new(l_opts)

              if args[:log_file] and args[:log_file].instance_of?(String)
                dev = args[:log_file]
                a_opts = Hash.new
                a_opts[:filename] = dev
                a_opts[:layout] = layout
                a_opts.merge! l_opts

                name = case dev
                         when String; dev
                         when File; dev.path
                         else dev.object_id.to_s end

                appender =
                    case dev
                      when String
                        ::Logging::Appenders::RollingFile.new(name, a_opts)
                      else
                        ::Logging::Appenders::IO.new(name, dev, a_opts)
                    end
                logger.add_appenders appender
              end

              scheme = ::Logging::ColorScheme.new( 'christo', :levels => {
                  :trace => [:blue, :on_white],
                  :debug => :cyan,
                  :info  => :green,
                  :step  => :green,
                  :warn  => :yellow,
                  :error => :red,
                  :fatal => [:red, :on_white],
                  :todo  => :purple,
              }).scheme
              scheme['todo']  = "\e[38;5;55m"
              l_opts[:color_scheme] = 'christo'
              layout = ::Logging::Layouts::Pattern.new(l_opts)

              appender = logger.appenders[0]
              appender.layout = layout
              logger.remove_appenders appender
              logger.add_appenders appender

              logger.level = args[:log_level] ? args[:log_level] : :warn
              logger.trace = true if args[:trace]
              @args = args
            rescue Gem::LoadError
              logger = FakeLogger.new
            rescue => e
              # not installed
              logger = FakeLogger.new
            end
            @TODO = {} if @TODO.nil?
          end # if args
          @logger = alogger || logger
        end # unless logger
        logger
      end # getLogger
    end # module Logging
  end # module MixLib
end # module DLDInternet