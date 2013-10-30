#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

class ::Chef::DataBagItem

  # --------------------------------------------------------------------------------------------------------------------
  def generate_json(part)
    self.to_json
  end

  # --------------------------------------------------------------------------------------------------------------------
  def generate_rb(part)
    part.logger.todo "generate_rb", true
    src = []
    src << "name '#{@name}'"
    src << "description '#{@description}'"
    src.join("\n")
  end

end
