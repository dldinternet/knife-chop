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

class ::Chef::Knife::EnvironmentFromFile

  # --------------------------------------------------------------------------------------------------------------------
  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize(argv=[])
    super(argv)
    @rsrctype = 'environment'
    @location = 'environments'
  end

  # --------------------------------------------------------------------------------------------------------------------
  def load_environment(env)
    updated = loader.load_from("environments", env)
    updated.save
    output(format_for_display(updated)) if config[:print_after]
    ui.step("Updated Environment #{updated.name}")
  end

  # --------------------------------------------------------------------------------------------------------------------
  def run
    if config[:all] == true
      load_all_environments
    else
      if @name_args[0].nil?
        show_usage
        ui.fatal("You must specify a file to load")
        exit 1
      end

      @name_args.each do |arg|
        load_environment(arg)
      end
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  private
  # --------------------------------------------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------------------------------------------
  def translate_all_environments
    environments = find_all_environments
    if environments.empty?
      ui.fatal("Unable to find any environment files in '#{environments_path}'")
      exit(1)
    end
    environments.each do |env|
      translate_environment(env)
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  def translate_environment(env)
    updated = loader.load_from("environments", env)
    updated.translate(@config,env)
    output(format_for_display(updated)) if config[:print_after]
    ui.info("Translated Environment #{updated.name}")
  end

end
