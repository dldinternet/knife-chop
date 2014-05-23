#
# Author:: Christo De Lange (<opscode@dldinternet.com>)
# Copyright:: Copyright (c) 2013 DLDInternet, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "awesome_print"
require 'chef/knife'
require 'chef/knife/chop/version'
require 'chef/knife/chop/logging'
require 'chef/knife/chop/errors'
require 'logging'

class Chef
  class Knife
    attr_accessor :logger
    attr_accessor :verbosity
    attr_accessor :LOGLEVELS
    attr_accessor :ALLPARTS
    attr_accessor :ALLACTIONS
		attr_accessor :prec_max

    def self.loglevels=(levels)
      @LOGLEVELS  = levels || [:trace, :debug, :step, :info, :warn, :error, :fatal, :todo]
    end

    def self.allparts=(parts)
      @ALLPARTS   = parts || [:environments, :roles, :databags, :cookbooks]
    end

    def self.allactions=(acts)
      @ALLACTIONS = acts || [:upload, :translate]
    end

    def self.loglevels
      @LOGLEVELS
    end

    def self.allparts
      @ALLPARTS
    end

    def self.allactions
      @ALLACTIONS
    end

    self.loglevels  = nil
    self.allparts   = nil
    self.allactions = nil

    module ChopBase
      class ::TrueClass
        def to_rb
          to_s
        end
        def yesno
          "yes"
        end
      end

      class ::FalseClass
        def to_rb
          to_s
        end
        def yesno
          "no"
        end
      end

      include ChopErrors

      include ChopLogging

      # --------------------------------------------------------------------------------
      def parsePartSymbol(v)
        if v.to_sym == :all
          ::Chef::Knife.allparts
        else
          s = v.to_sym
          allparts = [::Chef::Knife.allparts, :all].flatten
          unless allparts.include?(s)
            allparts.each{ |p|
              s = p if p.match(%r/^#{s}/)
            }
          end
          s = ::Chef::Knife.allparts if s == :all
          s
        end
      end

      # --------------------------------------------------------------------------------
      def parseActionSymbol(v)
        if v.to_sym == :all
          ::Chef::Knife.allactions
        else
          s = v.to_sym
          allactions = [::Chef::Knife.allactions, :all].flatten
          unless allactions.include?(s)
            allactions.each{ |p|
              s = p if p.match(%r/^#{s}/)
            }
          end
          s = ::Chef::Knife.allactions if s == :all
          s
        end
      end

      # --------------------------------------------------------------------------------
      def parseString(v)
        v
      end

      # --------------------------------------------------------------------------------
      def parsePath(v)
        File.expand_path(parseString(v))
      end

      # --------------------------------------------------------------------------------
      def parseList(v,s=',',method='parseString')
        parts = []
        a = v.split(%r/#{s}/)
        a.each{ |t|
          parts << send(method,t)
        }
        parts
      end

      # --------------------------------------------------------------------------------
      def parseOptionString(v,s=',',method='parseString')
        bags = []
        if v.match(%r'#{s}')
          bags << parseList(v,s,method)
        else
          bags << send(method,v)
        end
        bags.flatten
      end

      # --------------------------------------------------------------------------------
      def parsePrecedence(v)
        @prec_max += 1
        match = v.match(%r/^(json|rb|yaml)$/i)
        unless match
          m = "ERROR: Invalid precedence argument: #{v}. Accept only from this set: [json,rb,yaml]"
          puts m
          raise Exception.new(m)
        end
        s = { v => @prec_max }
        match = v.match(%r/^(\S+):(\d+)$/)
        if match
          begin
            a = match[1]
            i = match[2].to_i
            s = { a => i }
          rescue => e
            puts "ERROR: Unable to match precedence #{v}"
            raise e
          end
        end
        s
      end

      # --------------------------------------------------------------------------------
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog'
            require 'readline'
            require 'colorize'
            require 'inifile'
            require 'chef/knife/chop/chef_knife'
            require 'chef/environment'
            require 'chef/knife/core/object_loader'
            require 'chef/cookbook_loader'
            require 'chef/cookbook_uploader'
            require 'chef/knife/chop/cookbook_upload'
            require 'chef/knife/chop/data_bag_from_file'
            require 'chef/knife/chop/role_from_file'
            require 'chef/knife/chop/environment_from_file'
            require 'chef/knife/chop/chef_part'
            require 'chef/knife/chop/chef_environment'
            require 'chef/knife/chop/chef_role'
            #require 'chef/knife/chop/chef_data_bag_item'
            require 'chef/json_compat'
            require 'chef/knife/bootstrap'
            require 'chef/knife/chop/ui'
            Chef::Knife::Bootstrap.load_deps
          end

          attr_reader   :argv

          # This will print an args summary.
          option  :help,
                  :short        => "-h",
                  :long         => "--help",
                  :description  => "Show this message",
                  :show_options => true,
                  :exit         => 1
          # print the version.
          option  :version,
                  :short        => '-V',
                  :long         => "--version",
                  :description  => "Show version",
                  :proc         => Proc.new{ puts ::Knife::Chop::VERSION },
                  :exit         => 2
          option  :verbosity,
                  :short        => "-v",
                  :long         => "--[no-]verbose [LEVEL]",
                  :description  => "Run verbosely",
                  :proc         => lambda{|s|
                    if s.nil? or (s == '')
                      $CHOP.verbosity += 1
                    else
                      $CHOP.verbosity = v.gsub(%r/['"]*/, '').to_i
                    end
                  }
          option  :log_path,
                  :long         => '--log-path PATH',
                  :description  => "Log destination path"
          option  :log_file,
                  :long         => '--log-file PATH',
                  :description  => "Log destination file"
          option  :log_level,
                  :short        => '-l',
                  :long         => ['--log_level LEVEL','--log-level LEVEL'],
                  :description  => "Log level (#{::Chef::Knife.loglevels.to_s})",
                  :proc         => lambda{|v|
                    if ::Chef::Knife.loglevels.include? v.to_sym
                      v.to_sym
                    else
                      level = ::Chef::Knife.loglevels.select{|l| l.to_s.match(%r(^#{v}))}
                      unless level.size > 0
                        raise OptionParser::InvalidOption.new("Invalid log level: #{v}. Valid levels are #{::Chef::Knife.loglevels.ai}")
                      end
                      level[0].to_sym
                    end
                  },
                  :default      => :step
          option  :inifile,
                  :short        => "-f",
                  :long         => "--inifile FILE",
                  :description  => "INI file with settings"
          option  :parts,
                  :short        => "-R",
                  :long         => "--resources PARTS",
                  :description  => "Parts to upload #{[ :all, ::Chef::Knife.allparts].flatten }. Default: all",
                  :default      => ::Chef::Knife.allparts,
                  :proc         => lambda{|v|
                    parts = $CHOP.parseOptionString(v,',','parsePartSymbol')
                    parts.each{ |part|
                      raise ::OptionParser::InvalidOption.new("Invalid part: #{part.to_s}. Valid parts are: #{[::Chef::Knife.allparts, :all].to_s}") unless [::Chef::Knife.allparts, :all].flatten.include?(part.to_sym)
                    }
                    parts
                  }
          option  :depends,
                  :short        => "-I",
                  :long         => "--[no-]include-dependencies [yes|no|true|false|0|1|enable|disable]",
                  :description  => "Include Cookbook dependencies?, Default --include-dependencies or -I [1|yes|enable|true]",
                  :default      => true
          option  :dry_run,
                  :short        => "-n",
                  :long         => "--[no-]dry-run",
                  :description  => "Do a dry run, Default --no-dry-run",
                  :default      => false
          option  :cookbook_path,
                  :short        => "-P",
                  :long         => "--cookbook-path PATH",
                  :description  => "Cookbook search path, Default chef/cookbooks/:chef/vendor-cookbooks",
                  :default      => ["cookbooks/","vendor-cookbooks"],
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v,'[:,]','parsePath')
                  }
          option  :repo_path,
                  :long         => "--repo-path PATH",
                  :description  => "Chef repo path, Default ./chef",
                  :default      => "./chef",
                  #:required     => true,
                  :proc         => lambda{|v|
                    File.expand_path(v)
                  }
          option  :cookbooks,
                  :short        => "-c",
                  :long         => "--cookbooks COOKBOOKS",
                  :description  => "Cookbooks to upload (List separated by commas or --all. Default: role",
                  :default      => ['role'],
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v)
                  }
          option  :envs,
                  :short        => ["-e", "-E",],
                  :long         => "--environments REGEXLIST",
                  :description  => "Environments regex",
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v)
                  },
                  :default      => ['web.*']
          option  :databags,
                  :short        => "-b",
                  :long         => "--databags BAGS",
                  :description  => "Data bags to upload",
                  :default      => ['aws:s3_.*_dev;s3_ro_.*','users:web.*;christo.*;tmiller.*'],
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v)
                  }
          option  :roles,
                  :short        => "-r",
                  :long         => "--roles ROLES",
                  :description  => "Roles to upload",
                  :default      => ["web.*"],
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v)
                  }

          option :all,
                 :short => "-a",
                 :long  => "--all",
                 :description => "Upload all items for resource group(s)"

          option :trace,
                 :short => "-t",
                 :long  => "--trace",
                 :boolean => true,
                 :default => false,
                 :description => "Trace logging locations (file::line)"

          # ------------------------------------------------------------------------------------------------------------
          # Cookbooks
          # ------------------------------------------------------------------------------------------------------------
          option :freeze,
                 :long => '--freeze',
                 :description => 'Freeze this version of the cookbook so that it cannot be overwritten',
                 :boolean => true

          #option :all,
          #       :short => "-a",
          #       :long => "--all",
          #       :description => "Upload all cookbooks, rather than just a single cookbook"

          option :force,
                 :long => '--force',
                 :boolean => true,
                 :description => "Update cookbook versions even if they have been frozen"

          # ------------------------------------------------------------------------------------------------------------
          # Data bags
          # ------------------------------------------------------------------------------------------------------------
          option :secret,
                 :short => "-s SECRET",
                 :long  => "--secret ",
                 :description => "The secret key to use to encrypt data bag item values"

          option :secret_file,
                 :long => "--secret-file SECRET_FILE",
                 :description => "A file containing the secret key to use to encrypt data bag item values"


          # ------------------------------------------------------------------------------------------------------------
          option  :precedence,
                  :long         => "--precedence PREC",
                  :description  => "Precedence order of parts extensions. Default: json:1,rb:2 or json,rb == [json rb] == { json => 1, rb => 2 } == .rb files will be used when there is both a .json and .rb",
                  :default      => %w(json rb),
                  :proc         => lambda{|v|
                    prec = $CHOP.parseOptionString(v,',', 'parsePrecedence')
                    prec.sort{|x,y| x.values.shift <=> y.values.shift }.map{|e| e.keys.shift }
                  }
          option  :actions,
                  :short        => '-a',
                  :long         => "--action ACTION",
                  :description  => "Actions to be performed #{[ :all, ::Chef::Knife.allactions].flatten }. Default: upload",
                  #:default      => [:upload],
                  :proc         => lambda{|v|
                    actions = $CHOP.parseOptionString(v,',','parseActionSymbol')
                    actions.each{ |act|
                      raise ::OptionParser::InvalidOption.new("Invalid action: #{act.to_s}. Valid actions are: #{[ :all, ::Chef::Knife.allactions].flatten.to_s}") unless [ :all, ::Chef::Knife.allactions].flatten.include?(act.to_sym)
                    }
                    actions
                  }
          option  :translate,
                  :long         => "--translate PREC",
                  :description  => "Translate parts. Default: json,rb == { :from => 'json', :to => 'rb' } == .json files will be read and .rb equivalents will be saved",
                  :default      => %w(json rb),
                  :proc         => lambda{|v|
                    $CHOP.parseOptionString(v)
                  }
        end
      end

      # --------------------------------------------------------------------------------
      # Create a new instance of the current class configured for the given
      # arguments and options
      def initialize(argv=[])
        @argv       = argv
        $CHOP       = self
        @verbosity  = 0
        @inis       = []
        @use_knife_api = true

        @stop = false
        @prec_max = 0
        @TODO = {}
        @actors = {}

        super
      end

      # --------------------------------------------------------------------------------
      def build_option_arguments(opt_setting)
        arguments = super
        arguments.flatten
      end

      # --------------------------------------------------------------------------------
      def parse_options(args,source=nil)
        argv = super(args)

        @config = parse_and_validate_options(@config,source ? source : "ARGV - #{__LINE__}")
        v = @config[:depends]
        m = (v.is_a?(String) && v.downcase.match(%r/^(no|false|disable|0)/) )
        @config[:depends] = (v === true) || (m.nil? ? true : false)

        unless @config[:actions]
          @config[:actions] = [ argv[1].to_sym ] # self.class.name.gsub(%r(Chef::Knife::Chop), '').downcase
        end
        @actors[argv[1].to_sym] = self
        others = @config[:actions].select{|a|
          a != argv[1].to_sym
        }
        index   = args.index '--action'
        others.each{|a|
          args[1] = a.to_s
          unless index.nil?
            args[index+1] = a.to_s
          end
          subcommand_class = ::Chef::Knife.subcommand_class_from(args)
          subcommand_class.load_deps
          instance = subcommand_class.new(args)
          instance.configure_chef
          @actors[a] = instance
        }
        argv
      end

      module ::Logging
        class << self
          def levelnames=(lnames)
            remove_const(:LNAMES)
            const_set(:LNAMES, lnames)
          end
          def levelnames()
            LNAMES
          end
        end
      end

      # --------------------------------------------------------------------------------
      def configure_chef
        super
        @config[:log_opts] = lambda{|mlll| {
            :pattern      => "%#{mlll}l: %m %C\n",
            :date_pattern => '%Y-%m-%d %H:%M:%S',
          }
        }

        @logger = getLogger(@config)
        @ui = Chef::Knife::ChopUI.new(@logger,@config)
        Chef::Log.logger = @logger
      end

      def run_with_pretty_exceptions
        unless self.respond_to?(:run)
          ui.error "You need to add a #run method to your knife command before you can use it"
        end
        enforce_path_sanity

        raise ChopOptionError.new("The --repo-path '#{@config[:repo_path]}' is invalid!") unless File.directory?(@config[:repo_path])

        run
      rescue ChopOptionError => e
        raise if Chef::Config[:verbosity] == 2
        humanize_exception(e)
        exit 100
      rescue ChopError => e
        humanize_exception(e)
        exit 101
      end

      # --------------------------------------------------------------------------------
      private
      # --------------------------------------------------------------------------------

      # --------------------------------------------------------------------------------
      def parseINIFile(options=nil)
        options = @config unless options
        if options.key?(:inifile)
          logStep "Parse INI file - #{options[:inifile]}"
          raise ChopError.new("Cannot find inifile (#{options[:inifile]})") unless File.exist?(options[:inifile])
          raise ChopError.new("Recursive call to inifile == '#{options[:inifile]}'") if @inis.include?(options[:inifile])
          ini = nil
          begin
            ini = IniFile.load(options[:inifile])
            @inis << options[:inifile]
            ini['global'].each { |key, value|
              #puts "#{key}=#{value}"
              ENV[key]=value
            }
            argv=[]
            cli = ini['cli'] || []
            cli.each{ |key,value|
              argv << key.gsub(%r/:[0-9]+$/, '').gsub(%r/^([^-])/, '--\1')
              argv << value
            }
            if argv.size > 0
              parse_options(argv,"INI-#{options[:inifile]}")
            end
          rescue => e
            puts e.message.light_red
            raise e
          end
        end
        options
      end

      # -----------------------------------------------------------------------------
      def setDefaultOptions(options)
        @options.each{|name,args|
          if args[:default]
            options[name] = args[:default] unless options[name]
          end
        }
        setOrigins(options,'default')
      end

      # -----------------------------------------------------------------------------
      def validate_options(options=nil)
        options = @config unless options

        # Check for the necessary environment variables
        logStep ("Check ENVironment")
        env = ENV.to_hash
        missing = {}
        %w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY KNIFE_CHEF_SERVER_URL KNIFE_CLIENT_KEY KNIFE_CLIENT_NAME).each { |k|
          missing[k] = true unless ENV.has_key?(k)
        }

        if missing.count() > 0
          #@logger.error "Missing keys: #{missing.keys.ai}"
          raise ChopError.new("Missing environment variables: #{missing.keys}")
        end
      end

      # -----------------------------------------------------------------------------
      def parse_and_validate_options(options=nil,source='ARGV')
        options = @config unless options
        setOrigins(options,source)

        #options = parseOptions(options,source)
        unless @origins and @name_key_map
          # These are the essential default options which things like parseOptions depend on
          {
              :verbosity    => @verbosity,
              :auto_purge   => false,
          }.each{ |k,v|
            options[k] = v unless options[k]
          }
          setOrigins(options,'hardcoded-default')

          @name_key_map    = {} unless @name_key_map
          @options.each{ |name,args|
            @name_key_map[name]  = {} unless @name_key_map[name]
            [:short,:long,:description].each{|key|
              @name_key_map[name][key] = args[key] if args[key]
            }
          }
        end

        begin
          parseINIFile(options)
          setDefaultOptions(options)
          # Check for all the necessary options
          validate_options(options)
          checkArgsSources(options)
          #findRootPath(options)
        rescue ChopError => e
          puts e.message.light_red
          exit -1
        rescue Exception => e
          puts e.message.light_red
          exit -2
        end

        options
      end

      # ---------------------------------------------------------------------------------------------------------------
      def setOrigins(options,source)
        @origins = {} unless @origins
        options.each { |key, val|
          @origins[key] = source unless (@origins[key])
        }
      end

      # ---------------------------------------------------------------------------------------------------------------
      def checkArgsSources(options)
        if @origins
          missing = @origins.select{ |k,v|
            v.nil?
          }.map{ |k,v| k }
          raise ChopError.new("Missing origins: #{missing.ai}") if missing.size > 0
        end
      end

      ## ---------------------------------------------------------------------------------------------------------------
      #def findRootPath(options)
      #  @root_path = ''
      #  cbpaths = @config[:cookbook_path]#.split(File::PATH_SEPARATOR)
      #  common  = cbpaths[0]
      #  begin
      #    common = File.dirname(common)
      #    ayes   = 1
      #    cbpaths[1..-1].each{ |cbp|
      #      if File.dirname(cbp).match(%r(^#{common}))
      #        ayes += 1
      #      end
      #    }
      #    @root_path = common
      #  end while ((common != '') and (ayes != cbpaths.size))
      #  @root_path
      #end

      # --------------------------------------------------------------------------------
      def getPathSet(want, path, exts=nil)
        raise ChopInternalError.new("Bad call to #{self.class.name}.getPathSet: want == nil") unless want
        @logger.debug "Look for #{want.ai} in #{[path]} with #{exts} extensions"
        if exts.nil?
          exts = @config[:precedence]
        end
        file_regex=%r/^(\S+)\.(#{exts.join('|')})$/
        if exts.empty?
          file_regex=%r/^(\S+)()$/
          exts=['']
        end
        regex = "^(#{want.join('|')})$"
        set = {}
        chef = @config[:repo_path]
        raise ChopError.new "Oops! Where is the '#{chef}' directory? Also check cookbook path '#{@config[:cookbook_path]}'" unless File.directory?(chef)
        abs = File.realpath(File.expand_path("#{chef}/#{path}"))
        raise ChopError.new "Oops! Does 'chef/#{path}' directory exist?" unless File.directory?(abs)
        Dir.glob("#{abs}/*").each{ |f|
          match = File.basename(f).match(file_regex)
          if match
            name = match[1]
            ext  = match[2]
            set[ext] = {} unless set[ext]
            @logger.trace "#{name} =~ #{regex}"
            set[ext][name] = f if name.match(regex)
          end
        }
        @logger.debug "getPathSet set=#{set.ai}"
        res = {}
        # Iterate extension sets in increasing precedence order ...
        # Survivor will be the most desireable version of the item
        # i.e. the .rb environment, role, data bag, etc. will be preferred over the .json version
        exts.each{ |e|
          h = set[e]
          if h
            h.each{ |n,f|
              @logger.warn "Ignoring #{File.basename(res[n])}" if res[n]
              res[n] = f
            }
          else
            @logger.warn "'#{e}' set is empty! (No #{path}/*.#{e} files found using precedence #{exts})"
          end
        }
        set = res
      end

      # --------------------------------------------------------------------------------
      def todo(msg)

        # Regular expression used to parse out caller information
        #
        # * $1 == filename
        # * $2 == line number
        # * $3 == method name (might be nil)
        caller_rgxp = %r/([-\.\/\(\)\w]+):(\d+)(?::in `(\w+)')?/o
        #CALLER_INDEX = 2
        caller_index = ((defined? JRUBY_VERSION and JRUBY_VERSION[%r/^1.6/]) or (defined? RUBY_ENGINE and RUBY_ENGINE[%r/^rbx/i])) ? 1 : 2
        stack = Kernel.caller[caller_index]
        return if stack.nil?

        match = caller_rgxp.match(stack)
        file = match[1]
        line = Integer(match[2])
        modl = match[3] unless match[3].nil?

        unless @TODO[line]
          le = ::Logging::LogEvent.new(@logger, ::Logging::LEVELS['todo'], msg, true)
          @logger.logEvent(le) unless @TODO[line]
          @TODO[line] = true
        end
      end

      # --------------------------------------------------------------------------------
      def matches(string, criterium)
        if criterium =~ %r/[\.\+\*\(\)\|\,\{\}\?\[\]\^\$]|\\[sSdDAzwWb]/
          string.match(%r/#{criterium}/)
        else
          string == criterium
        end
      end

      # --------------------------------------------------------------------------------
      def execute(cmd,lead)
        exit 1 if stop
        print lead if @logger.level < 4
        system cmd
      end

      # --------------------------------------------------------------------------------
      def watch_for_break
        Thread.new do
          s=$stdin.read
          #puts "Consumed existing input: '#{$stdin.read}'"
          loop do
            s = gets.chomp
            if s != ""
              puts "Interrupted! You entered '#{s}'"
              @stop = true
              exit
            end
          end
        end
      end

      # --------------------------------------------------------------------------------
      def callCmdProc(cmdp, a, b, c)
        ret = nil
        begin
          if cmdp.is_a?(String)
            ret = cmdp
          elsif cmdp.is_a?(Proc)
            ret = cmdp.call(a, b, c)
          else
            raise ChopInternalError.new("'#{cmdp}' is not a Proc, Lambda or String!")
          end
        rescue ChopInternalError => e
          raise e
        rescue => e
          @logger.fatal "#{e.class.name} #{e.message}"
          raise ChopError.new("#{e.class.name} #{e.message}")
        end
        ret
      end

      # --------------------------------------------------------------------------------
      def databags(options=nil,exts=nil)
        options = @config unless options
        unless @databags

          want = Hash.new
          options[:databags].each{ |b|
            match = b.match(%r/^(.*):(.*)$/)
            if match
              want[match[1]] = parseOptionString(match[2],';')
            end
          }
          @logger.debug want.ai

          chef = options[:repo_path]
          raise ChopError.new "Oops! Where is the '#{chef}' directory? Also check cookbook path '#{options[:cookbook_path]}'" unless File.directory?(chef)

          @databags={}
          Dir.glob("#{chef}/data_bags/*").each{ |d|
            if File.directory?(d)
              name  = File.basename(d)
              regex = "^(#{want.keys.join('|')})"
              match = matches(name,regex)
              if match
                @databags[name] = getPathSet(want[name], "data_bags/#{name}", exts)
                @logger.info "Data bags list: #{@databags[name].values.map{|f| "#{name}/#{File.basename(f)}" }}"
              end
            end
          }
        end
        @databags
      end

      # --------------------------------------------------------------------------------
      def roles(options=nil,exts=nil)
        options = @config unless options
        unless @roles
          @roles = getPathSet(options[:roles], 'roles', exts)
          @logger.info "Roles list: #{@roles.values.map{|f| File.basename(f)}.ai}"
        end
        @roles
      end

      # --------------------------------------------------------------------------------
      def environments(options=nil,exts=nil)
        options = @config unless options
        unless @environments
          @environments = getPathSet(options[:envs], 'environments', exts)
          @logger.info "Environments list: #{@environments.values.map{|f| File.basename(f)}.ai}"
        end
        @environments
      end

    end
  end
end


