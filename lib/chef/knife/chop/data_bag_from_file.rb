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

end
