#
# Author:: Christo De Lange <opscode@dldinternet.com>
# Monkey patch for Chef::Knife::EnvironmentFromFile
#
require 'chef/knife/environment_from_file'

class ::Chef::Knife::EnvironmentFromFile

  # --------------------------------------------------------------------------------------------------------------------
  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize(argv=[])
    super(argv)
    @rsrctype = 'environment'
    @location = 'environments'
  end

  # DLDInternet monkey patch of original
  def load_environment(env)
    updated = loader.load_from("environments", env)
    updated.save
    output(format_for_display(updated)) if config[:print_after]
    # BEGIN DLDInternet change
    ui.step("Updated Environment #{updated.name}")
    # END DLDInternet change
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
    ui.step("Translated Environment #{updated.name}")
  end

end
