#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Seth Falcon (<seth@opscode.com>)
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

class ::Chef::Knife::DataBagFromFile

  # --------------------------------------------------------------------------------------------------------------------
  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize(argv=[])
    super(argv)
    @rsrctype = 'databag'
    @location = 'data_bags'
  end

  ## --------------------------------------------------------------------------------------------------------------------
  #def translate()
  #  if config[:all] == true
  #    translate_all_data_bags()
  #  else
  #    if @name_args[0].nil?
  #      show_usage
  #      ui.fatal("You must specify a file to translate")
  #      exit 1
  #    end
  #
  #    @data_bag = @name_args.shift
  #    translate_data_bag_items(@data_bag, @name_args)
  #  end
  #end

  ## --------------------------------------------------------------------------------------------------------------------
  #def translate_data_bag_items(data_bag, items = nil)
  #  items ||= find_all_data_bag_items(data_bag)
  #  item_paths = normalize_item_paths(items)
  #  item_paths.each do |item_path|
  #    item = loader.load_from("#{data_bags_path}", data_bag, item_path)
  #    dbag = ::Chef::DataBagItem.new
  #    dbag.data_bag(data_bag)
  #    dbag.raw_data = item
  #    part = ::Chef::Part.new(dbag,location)
  #    part.translate(@config)
  #    resource = part.resource
  #    output(format_for_display(resource)) if config[:print_after]
  #    ui.info("Translated #{@rsrctype.capitalize} #{resource.name}")
  #  end
  #end
  #
  ## --------------------------------------------------------------------------------------------------------------------
  #def data_bags_path
  #  @data_bag_path ||= "data_bags"
  #end
  #
  ## --------------------------------------------------------------------------------------------------------------------
  #def translate_all_data_bags
  #  loader.find_all_object_dirs("./#{data_bags_path}")
  #end
  #
  ## --------------------------------------------------------------------------------------------------------------------
  #def find_all_data_bag_items(data_bag)
  #  loader.find_all_objects("./#{data_bags_path}/#{data_bag}")
  #end
  #
  ## --------------------------------------------------------------------------------------------------------------------
  #def translate_all_data_bags(args)
  #  data_bags = args.empty? ? find_all_data_bags : [args.shift]
  #  data_bags.each do |data_bag|
  #    load_data_bag_items(data_bag)
  #  end
  #end

end
