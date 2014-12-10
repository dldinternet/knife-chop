#
# Author:: Christo De Lange <opscode@dldinternet.com>
# Monkey patch for Chef::Knife::DataBagFromFile
#
require 'chef/knife/data_bag_from_file'

class ::Chef::Knife::DataBagFromFile

  # --------------------------------------------------------------------------------------------------------------------
  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize(argv=[])
    super(argv)
    @rsrctype = 'databag'
    @location = 'data_bags'
  end

  if Chef::VERSION.split('\.')[0].to_i < 12
  # DLDInternet monkey patch of original
  def load_data_bag_items(data_bag, items = nil)
    items ||= find_all_data_bag_items(data_bag)
    item_paths = normalize_item_paths(items)
    item_paths.each do |item_path|
      item = loader.load_from("#{data_bags_path}", data_bag, item_path)
      item = if use_encryption
               secret = read_secret
               Chef::EncryptedDataBagItem.encrypt_data_bag_item(item, secret)
             else
               item
             end
      dbag = Chef::DataBagItem.new
      dbag.data_bag(data_bag)
      dbag.raw_data = item
      dbag.save
      # BEGIN changes DLDInternet
      ui.info("Updated data_bag_item[#{dbag.data_bag}::#{dbag.id}]")
      # END changes DLDInternet
    end

  end
  end
end
