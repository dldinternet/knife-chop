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
require 'chef/knife/chop/chef_part'

class ::Chef::Role
  attr_reader :logger

  # --------------------------------------------------------------------------------------------------------------------
  def generate_json(part)
    self.to_json
  end

  # --------------------------------------------------------------------------------------------------------------------
  def generate_rb(part)
    src = []
    src << "name '#{@name}'"
    src << "description '#{@description}'"
    src << part.hash_to_rb('default_attributes')
    src << part.hash_to_rb('override_attributes')
    src << part.run_lists_to_rb(@run_list) if @run_list
    src << part.run_lists_to_rb(@env_run_lists,'env_run_lists') if @env_run_lists
    src.join("\n")
  end

end
