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
#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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
require 'chef/knife/chop/chef_part'

class ::Chef::Knife
  attr_reader :rsrctype
  attr_reader :location

  # --------------------------------------------------------------------------------------------------------------------
  def translate()
    if config[:all]
      translate_all()
    else
      if @name_args[0].nil?
        show_usage
        ui.fatal("You must specify a file to translate")
        exit 1
      end

      @name_args.each do |arg|
        translate_one(arg)
      end
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  private
  # --------------------------------------------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------------------------------------------
  def translate_all()
    set = self.send("find_all_#{@location}")
    if set.empty?
      ui.fatal("Unable to find any #{@rsrctype} files in '#{subc.send("#{@rsrctype}_path")}'")
      exit(1)
    end
    set.each do |ent|
      translate_one(ent)
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  def translate_one(ent)
    location = loader.find_file(@location, ent)
    resource = loader.load_from(@location, ent)
    part = ::Chef::Part.new(resource,location)
    part.translate(@config)
    resource = part.resource
    output(format_for_display(resource)) if config[:print_after]
    ui.info("Translated #{@rsrctype.capitalize} #{resource.name}")
  end

end
