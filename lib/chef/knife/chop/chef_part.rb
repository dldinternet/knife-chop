#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Author:: Seth Falcon (<seth@opscode.com>)
# Author:: John Keiser (<jkeiser@ospcode.com>)
# Author:: Kyle Goodwin (<kgoodwin@primerevenue.com>)
# Copyright:: Copyright 2010-2011 Opscode, Inc.
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
require 'json'
require 'chef/knife/chop/translate'

require 'chef/knife/chop/errors'
include ChopErrors

require 'chef/run_list'
# ======================================================================================================================
class ::Chef::RunList
  def to_rb
    items = @run_list_items.map{|i|
      i.to_rb
    }
    "[ #{items.join(",\n")} ]"
  end
end

require 'chef/run_list/run_list_item'
# ======================================================================================================================
class ::Chef::RunList::RunListItem
  def to_rb
    "'#{@type}[#{@name}#{@version ? "@#{@version}" :""}]'"
  end
end

# ======================================================================================================================
class ::Object
  def to_rb
    to_s
  end
end

# ======================================================================================================================
class ::Hash
  def to_rb
    self.inspect
  end
  def inspect
    if size == 0
      '{}'
    else
      a = keys.inject([]) do |a, key|
        k = "#{key}:"
        unless key.match(%r(^[\w]+$))
          if key.match(%r([']))
            q = '"'
          else
            q = "'"
          end
          k = "#{q}#{key}#{q} =>"
        end
        v = fetch(key)
        if v.is_a?(String)
          if v.match(%r('))
            a << "#{k} \"#{v}\""
          else
            a << "#{k} '#{v}'"
          end
        else
          a << "#{k} #{v.to_rb}"
        end
      end
      "{\n #{a.join(",\n")},\n }"
    end
  end
end

class ::Chef
  class Part
    attr_accessor :resource
    attr_accessor :location
    attr_reader   :logger
    attr_reader   :from
    attr_reader   :to

    def initialize(resource,path)
      self.resource = resource
      self.location = path
    end

    def translate(config)
      @config = config
      @logger = @config[:logger]
      @from,@to = @config[:translate]
      @logger.debug "#{@resource.class.name} To #{@to}"
      unless self.resource.respond_to?("generate_#{@to}")
        raise ChopInternalError.new("Unable to support translation '#{@from}' --> '#{@to}' "+
                                        "because #{self.resource.class.name} CANNOT 'generate_#{@to}'")
      end

      str = self.send("translate_to_#{@to}")
    end

    # --------------------------------------------------------------------------------------------------------------------
    def translate_to_json()
      obj = JSON.parse(self.resource.generate_json(self))
      json = JSON.pretty_generate(obj)
      save_source(json,"json")
    end

    # --------------------------------------------------------------------------------------------------------------------
    def hash_to_rb(hash)
      line = ["# #{hash}()"]
      if self.resource.send(hash).size > 0
        line =  ["#{hash}( "]
        self.resource.send(hash).each{|k,v|
          s = v.to_rb
          #s = s.gsub(%r/"'/, %(``')).gsub(%r/'"/, %('``)).gsub(%r/"/, "'").gsub(%r/``'/, %("')).gsub(%r/'``/, %('"))
          unless k.match(%r([\.\-]))
            line << "#{k}: #{s},"
          else
            line << "'#{k}' => #{s},"
          end
        }
        #line[-1].gsub!(%r(,\s*$), "")
        line << ")"
      end
      line.join("\n")
    end

    ## --------------------------------------------------------------------------------------------------------------------
    #def cookbook_versions_to_rb(cookbook_versions)
    #  line = ["# cookbook_versions()"]
    #  if cookbook_versions.size > 0
    #    line =  ["cookbook_versions( "]
    #    cookbook_versions.map{|k,v|
    #      line << "#{k}: #{v.to_s.gsub(%r/"/, "'")},"
    #    }
    #    line[-1].gsub!(%r(,\s*$), "")
    #    line << ")"
    #  end
    #  line.join("\n")
    #end

    # --------------------------------------------------------------------------------------------------------------------
    def run_lists_to_rb(run_lists,name='run_lists')
      line = ["# #{name}()"]
      if run_lists.size > 0
        line =  ["#{name}( "]
        run_lists.map{|k,v|
          line << "'#{k}' => #{v.to_rb},"
        }
        line[-1] = line[-1].gsub(%r(\n), "<nl>").gsub(%r(<nl>$), "").gsub(%r(,\s*$), "").gsub(%r(<nl>), "\n")
        line << ")"
      end
      line.join("\n")
    end

    # --------------------------------------------------------------------------------------------------------------------
    def translate_to_rb()
      #rb = Eden::Formatter.format_source(to_rb)
      rb = ::RBeautify.beautify_string :ruby, @resource.generate_rb(self)
      #rb = @resource.generate_rb(self)
      #sexp = Ripper::SexpBuilder.new(rb).parse
      #puts Sorcerer.source(sexp, multiline: true, indent: true)
      save_source(rb, "rb")
    end

    # --------------------------------------------------------------------------------------------------------------------
    def save_source(source,ext)
      @logger.info "Saving '#{ext}'"
      location = self.location.gsub(%r(\.#{@from}$), ".#{@to}")
      @logger.debug "Location: #{location}"
      #@logger.debug source
      File.open(location, 'w') do |f|
        f.write source
      end
    end

  end
end
