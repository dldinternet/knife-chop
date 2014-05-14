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
require 'chef/exceptions'
require 'chef/knife/chop_base'
require 'chef/knife/chop_translate' # Because knife chop upload --action translate ...

class Chef
  class Knife
    class ChopUpload < Knife

      include ChopBase

      banner "knife chop upload (options)"

      # --------------------------------------------------------------------------------
      def run
        $stdout.sync = true
        watch_for_break

        @config[:parts].each{ |p|
          @config[:actions].each{ |a|
            actor = @actors[a]
            raise ChopInternalError.new("Actor for action '#{a.to_s}' cannot be nil!") unless actor
            method = %(#{a.to_s}_#{p.to_s})
            raise ChopError.new "Internal error: Method '#{method}' is not implemented in actor #{actor.class.name}!" unless actor.respond_to?(method,true)
            actor.send(method)
          }
        }
      end

      # --------------------------------------------------------------------------------
      private
      # --------------------------------------------------------------------------------

      # --------------------------------------------------------------------------------
      def uploadSet(set,args={})
        raise ChopInternalError.new "Incorrect use of uploadSet method from #{Kernel.caller[0].ai}" unless args.is_a?(Hash)
        raise ChopError.new "Must specify the :resource type" unless args[:resource]
        unless set.size > 0
          @logger.warn("The upload set is empty!")
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

        if @use_knife_api
          argv = "#{rsrc} #{verb}".split(%r(\s+))
          klass= Chef::Knife.subcommand_class_from(argv)
          subc = klass.new()
          subc.config = @config.dup
          subc.config[:cookbook_path] = @config[:cookbook_path].map{|p| p.match(%r(^/)) ? p : "#{@config[:repo_path]}/#{p}" } #.join(::File::PATH_SEPARATOR)
          subc.ui = ::Chef::Knife::ChopUI.new(@logger,@config)
        end

        if args[:aggregate] and @use_knife_api
          subc.name_args << xtra if xtra != ''
          subc.name_args << set.map{ |name,file|
            extname  = File.extname(file)
            extname.gsub!(%r/^\./,'')
            case extname
              when /^yaml$/i
                begin
                  json = File.join(File::SEPARATOR, [ Dir::Tmpname.tmpdir, Dir::Tmpname.make_tmpname([name, '.json'], nil) ])
                  @logger.debug("#{name}.#{extname} => #{json}")
                  require 'json'
                  require 'yaml'

                  yaml_s = YAML::load(IO.read(file))
                  json_s = JSON.dump(yaml_s)
                  IO.write(json,json_s)
                rescue Exception => e
                  raise ChopError.new("#{e.class.name} - #{e.message}")
                end
                json
              when /^(rb|json)$/
                # noop
                file
              else
                raise ChopError.new("'#{extname}' files are not supported!")
            end
          }
          subc.name_args.flatten!
          #cmd = callCmdProc(filp, cmd, set.map{|name,file| name}.to_s, set.map{|name,file| file}.join(' '))
          @logger.info "#{cmd} #{set.map{|name,file| file}.ai} ... "
          @logger.info "#{cmd} #{subc.name_args.ai} ... "
          unless @config[:dry_run]
            begin
              subc.run
            rescue => e
              @logger.error "#{e.class.name} #{e.message} #{e.response.body if e.respond_to?('response')}"
              raise e
            end
          end
        else
          set.each{ |name,file|
            cmd = callCmdProc(filp, cmd, name, file)
						fLog = false
            if rsrc == 'cookbook'
	            fLog = @logger.info "#{args[:environment]}:#{File.basename(file)} (Dependencies: #{@config[:depends]})"
	          else
	            fLog = @logger.info File.basename(file)
	          end
	          @logger.debug "... #{cmd}" if fLog
            if @use_knife_api
              unless @config[:dry_run]
                subc.name_args = rsrc == 'cookbook' ? [ name ] : [ file ]
                subc.run
              end
            else
              unless @config[:dry_run]
                execute cmd,"#{File.basename(file)} ... "
              end
            end
          }
        end
      end

      # --------------------------------------------------------------------------------
      def upload_environments
        logStep "Upload environments"
        uploadSet(environments, :resource => 'environment', :aggregate => true )
      end

      # --------------------------------------------------------------------------------
      def upload_roles
        logStep "Upload roles"
        uploadSet(roles, :resource => 'role', :aggregate => true)
      end

      # --------------------------------------------------------------------------------
      def upload_databags
        logStep "Upload data bags"
        want = Hash.new
        @config[:databags].each{ |b|
          match = b.match(%r/^(.*):(.*)$/)
          if match
            want[match[1]] = parseOptionString(match[2],'[:;]')
          end
        }
        @logger.debug want.ai
        databags={}
        Dir.glob(File.expand_path(@config[:repo_path])+'/data_bags/*').each{ |d|
          if File.directory?(d)
            name  = File.basename(d)
            regex = "^(#{want.keys.join('|')})"
            match = matches(name,regex)
            if match and want.has_key?(name)
              databags[name] = getPathSet(want[name], "data_bags/#{name}")
              @logger.debug "Data bags: (#{name}) #{databags[name].ai}"
            end
          end
        }
        @logger.info "Data bag list: (#{@config[:databags]}) #{databags.ai}"
        databags.each{ |bag,files|
          uploadSet(files, :resource => 'data bag', :extra => bag, :aggregate => true)
        }
      end

      # --------------------------------------------------------------------------------
      def cookbooks
        unless @cookbooks
          @cookbooks = {}
          @config[:cookbook_path].each{|p| # .split(%r/[,:]/)
            path=File.basename(p)
            @logger.debug "cookbook path: #{p} ==> #{path}"
            @cookbooks.merge! getPathSet(@config[:cookbooks], path, [])
            @logger.debug "Cookbook list: #{@cookbooks.ai} (dependencies: #{@config[:depends].yesno})"
          }
        end
        @cookbooks
      end

      # --------------------------------------------------------------------------------
      def upload_cookbooks
        logStep "Upload cookbooks"
        @logger.info "Cookbook list: #{cookbooks.ai} (dependencies: #{@config[:depends].yesno})"
        cbpaths = @config[:cookbook_path].dup.map!{|p|
          if p.match(%r(^/))
            p
          else
            File.expand_path("#{@config[:repo_path]}/#{p}")
          end
        }

        cmdp = lambda{ |resource,verb,xtra|
          "#{resource} #{verb} #{xtra} --cookbook-path #{cbpaths.join(File::PATH_SEPARATOR)}"
        }
        environments.each{ |name,file|
          @logger.info "Environment: #{name}"
          filp = lambda{ |cbcmd,cbname,cbfile|
            s = "#{cbcmd} -E #{name} #{@config[:depends] ? '--include-dependencies' : ''} #{cbname}"
            s
          }
          uploadSet(cookbooks, :resource => 'cookbook', :verb => 'upload', :command => cmdp, :fileproc => filp, :environment => name)
        }
      end

    end
  end
end
