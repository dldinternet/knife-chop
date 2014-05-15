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

require 'chef/knife/core/ui'
require 'chef/knife/chop/errors'

class Chef
  class Knife
    class ChopUI < ::Chef::Knife::UI
      include ChopErrors

      attr_reader :logger

      def initialize(logger, config)
        super($stdout, $stderr, $stdin, config)
        @logger = logger
        #define_ui_methods()
      end

      #def define_log_methods( ui )
      def msg(message)
        caller = Kernel.caller[0]
        match = caller.match(%r/([-\.\/\(\)\w]+):(\d+)(?::in `(\w+)')?/o)
        name = shifted(match[3])
        @logger.send(name, message)
      end

      #def define_ui_methods()
      #  class << self
      #    ::Logging::LEVELS.each{|name,level|
      #        code = <<-CODE
      #        def #{name}(str)
      #          msg(str)
      #        end
      #        CODE
      #        self.class.class_eval(code,__FILE__,__LINE__)
      #    }
      #  end
      #end
      def info(message)
        msg(message)
      end

      def step(message)
        msg(message)
      end

      def err(message)
        error(message)
      end

      def error(message)
        msg(message)
      end

      # Print a warning message
      def warn(message)
        msg(message)
      end

      # Print an error message
      def error(message)
        msg(message)
      end

      # Print a message describing a fatal error.
      def fatal(message)
        msg(message)
      end

      def method_missing(name, *args, &block)
        msg = "#{self.class.name}: Method missing: #{name}"
        @logger.fatal(msg)
        raise ChopInternalError.new(msg)
      end

      def shifted(name)
        num = ::Logging::LEVELS[name]+1
        case name
        when 'todo'
          'error'
        when 'err'
          'error'
        # when 'info'
        #   'debug'
        when 'debug'
          'trace'
        else
          name
        end
      end

    end
  end
end