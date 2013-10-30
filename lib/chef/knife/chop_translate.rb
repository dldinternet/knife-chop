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

require 'chef/knife/chop_base'
require 'chef/knife/chop_upload' # Because knife chop translate --action upload ...

class Chef
  class Knife
    class ChopTranslate < Knife

      include ChopBase

      # --------------------------------------------------------------------------------
      def run
        $stdout.sync = true
        watch_for_break

        @config[:parts].each{ |p|
          @config[:actions].each{ |a|
            actor = @actors[a]
            raise ChopInternalError.new("Actor for action '#{a.to_s}' cannot be nil!") unless actor
            method = %(#{a.to_s}_#{p.to_s})
            raise ChopInternalError.new "Internal error: Method '#{method}' is not implemented in actor #{actor.class.name}!" unless actor.respond_to?(method,true)
            actor.send(method)
          }
        }
      end

      # --------------------------------------------------------------------------------
      private
      # --------------------------------------------------------------------------------

      # --------------------------------------------------------------------------------
      def getNameArgs(xtra,set,key=nil)
        @logger.info "Translating these #{set.map{|name,file| file}.ai} ... "
        name_args = []
        name_args << xtra if xtra != ''
        name_args << key if key
        name_args << set.map{ |name,file|
          file
        }
        name_args.flatten
      end

      # --------------------------------------------------------------------------------
      def translateSet(set,args={})
        raise ChopInternalError.new "Incorrect use of translateSet method from #{Kernel.caller[0].ai}. Received #{args.class.name}" unless args.is_a?(Hash)
        raise ChopError.new "Must specify the :resource type" unless args[:resource]
        @logger.debug "Translate set: #{set.ai}"
        unless set.size > 0
          @logger.warn("The translate set is empty!")
          return
        end
        rsrc = args[:resource]
        verb = args[:verb] || "from file"
        xtra = args[:extra] || ''
        cmdp = args[:command] || lambda{|rsrc,verb,xtra|
          %(knife #{rsrc} #{verb} #{xtra})
        }
        filp = args[:fileproc] || lambda{|cmd,name,file|
          # name not used/needed
          %(#{cmd} #{file})
        }
        cmd = callCmdProc(cmdp, rsrc,verb,xtra)

        raise ChopInternalError.new("Translation not possible without using Chef/Knife API") unless @use_knife_api
        argv = "#{rsrc} #{verb}".split(%r(\s+))
        klass= Chef::Knife.subcommand_class_from(argv)
        subc = klass.new()
        subc.config = @config.dup
        subc.config[:logger] =
        subc.logger = @logger

        scna = []
        if args[:aggregate] and @use_knife_api
          if rsrc == 'data bag'
            set.each{|k,v|
              scna << getNameArgs(xtra,v,k)
            }
          else
            scna << getNameArgs(xtra,set)
          end
        else
          scna << set.map{ |name,file|
            if @use_knife_api
              "#{xtra} #{rsrc == 'cookbook' ? name : file}"
            else
              cmd = callCmdProc(filp, cmd, name, file)
              cmd
            end
          }
        end
        unless @config[:dry_run]
          begin
            scna.each{|batch|
              if args[:aggregate] and @use_knife_api
                subc.name_args = batch
                subc.translate()
              else
                batch.each{|a|
                  if @use_knife_api
                    subc.name_args = a
                    subc.translate()
                  else
                    a.each{|file,cmd|
                      execute cmd,"#{File.basename(file)} ... "
                    }
                  end
                }
              end
            }
          rescue => e
            @logger.error "#{e.class.name} #{e.message}"
            raise e
          end
        end
      end

      # --------------------------------------------------------------------------------
      def translate_environments()
        logStep "Translate environments"
        # We are only interested in the ext we are starting with!
        translateSet(environments(@config,[@config[:translate][0]]), :resource => "environment", :aggregate => true)
      end

      # --------------------------------------------------------------------------------
      def translate_roles()
        logStep "Translate roles"
        translateSet(roles(@config,[@config[:translate][0]]), :resource => "role", :aggregate => true)
      end

      # --------------------------------------------------------------------------------
      def translate_databags()
        @logger.warn("Data bags cannot be translated to Ruby! (yet?)")
        #logStep "Translate databags"
        #translateSet(databags(@config,[@config[:translate][0]]), :resource => "data bag", :aggregate => true)
      end

      # --------------------------------------------------------------------------------
      def translate_cookbooks()
        @logger.info("Cookbooks do not need to be translated to Ruby!")
      end

    end
  end
end
