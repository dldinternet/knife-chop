#
# Author:: Christo De Lange <opscode@dldinternet.com>
# Monkey patch for Chef::Knife::RoleFromFile
#
require 'chef/knife/role_from_file'

class ::Chef::Knife::RoleFromFile
  # --------------------------------------------------------------------------------------------------------------------
  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize(argv=[])
    super(argv)
    @rsrctype = 'role'
    @location = 'roles'
  end

  # --------------------------------------------------------------------------------------------------------------------
  private
  # --------------------------------------------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------------------------------------------
  def translate_all_roles
    roles = find_all_roles
    if roles.empty?
      ui.fatal("Unable to find any role files in '#{roles_path}'")
      exit(1)
    end
    roles.each do |env|
      translate_role(env)
    end
  end

  # --------------------------------------------------------------------------------------------------------------------
  def translate_role(env)
    updated = loader.load_from("roles", env)
    updated.translate(@config,env)
    output(format_for_display(updated)) if config[:print_after]
    ui.info("Translated Role #{updated.name}")
  end

end





