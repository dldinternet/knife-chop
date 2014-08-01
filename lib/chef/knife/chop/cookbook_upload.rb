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
if ::Chef::Knife.const_defined?('CookbookUpload')
  class ::Chef::Knife::CookbookUpload
    if self.const_defined?('CHECKSUM')
      remove_const(:CHECKSUM)
    end
    if self.const_defined?('MATCH_CHECKSUM')
      remove_const(:MATCH_CHECKSUM)
    end
  end
end
require 'chef/knife/cookbook_upload'
class ::String
  def plural(count)
    count > 1 ? self+'s' : self
  end
end

class ::Chef::Knife::CookbookUpload
  def run
    raise StandardError.new("I was crafted from Chef::Knife::VERSION == '11.6.2'. Please verify that #{self.class.name}.run is still relevant in your version '#{Chef::VERSION}'!") unless Chef::VERSION.match(%r/^11\.(6|8|10|12|14)/)
    # Sanity check before we load anything from the server
    unless config[:all]
      if @name_args.empty?
        show_usage
        ui.fatal("You must specify the --all flag or at least one cookbook name")
        exit 1
      end
    end

    config[:cookbook_path] ||= ::Chef::Config[:cookbook_path]

    if @name_args.empty? and ! config[:all]
      show_usage
      ui.fatal("You must specify the --all flag or at least one cookbook name")
      exit 1
    end

    assert_environment_valid!
    warn_about_cookbook_shadowing
    version_constraints_to_update = {}
    upload_failures = 0
    upload_ok = 0

    # Get a list of cookbooks and their versions from the server
    # to check for the existence of a cookbook's dependencies.
    @server_side_cookbooks = ::Chef::CookbookVersion.list_all_versions
    justify_width = @server_side_cookbooks.map {|name| name.size}.max.to_i + 2
    if config[:all]
      cookbook_repo.load_cookbooks
      cbs = []
      cookbook_repo.each do |cookbook_name, cookbook|
        cbs << cookbook
        cookbook.freeze_version if config[:freeze]
        version_constraints_to_update[cookbook_name] = cookbook.version
      end
      begin
        upload(cbs, justify_width)
      rescue ::Chef::Exceptions::CookbookFrozen
        ui.warn("Not updating version constraints for some cookbooks in the environment as the cookbook is frozen.")
      end
      ui.step("Uploaded all cookbooks.")
    else
      if @name_args.empty?
        show_usage
        ui.error("You must specify the --all flag or at least one cookbook name")
        exit 1
      end

      cookbooks_to_upload.each do |cookbook_name, cookbook|
        cookbook.freeze_version if config[:freeze]
        begin
          upload([cookbook], justify_width)
          upload_ok += 1
          version_constraints_to_update[cookbook_name] = cookbook.version
        rescue ::Chef::Exceptions::CookbookNotFoundInRepo => e
          upload_failures += 1
          ui.fatal("Could not find cookbook #{cookbook_name} in your cookbook path, skipping it")
          Log.debug(e)
          upload_failures += 1
        rescue ::Chef::Exceptions::CookbookFrozen
          ui.error("Not updating version constraints for #{cookbook_name} in the environment as the cookbook is frozen.")
          upload_failures += 1
        end
      end

      # BEGIN changes DLDInternet
      # upload_failures += @name_args.length - @cookbooks_to_upload.length
      #
      # if upload_failures == 0
      #   ui.info "Uploaded #{upload_ok} cookbook#{upload_ok > 1 ? "s" : ""}."
      # elsif upload_failures > 0 && upload_ok > 0
      #   ui.warn "Uploaded #{upload_ok} cookbook#{upload_ok > 1 ? "s" : ""} ok but #{upload_failures} " +
      #               "cookbook#{upload_failures > 1 ? "s" : ""} upload failed."
      # elsif upload_failures > 0 && upload_ok == 0
      #   ui.error "Failed to upload #{upload_failures} cookbook#{upload_failures > 1 ? "s" : ""}."
      #   exit 1
      # end
      upload_skips = @name_args.length - @cookbooks_to_upload.length

      if upload_failures == 0
        if upload_skips == 0
          ui.step "Uploaded #{upload_ok} cookbook".plural(upload_ok)+"."
        elsif upload_skips > 0 && upload_ok > 0
          ui.step "Uploaded #{upload_ok} #{'cookbook'.plural(upload_ok)} ok but #{upload_skips} #{'cookbook'.plural(upload_skips)} were not included."
        elsif upload_ok == 0
          ui.fatal "Did not upload any cookbooks."
          exit 1
        end
      elsif upload_failures > 0 && upload_ok > 0
        if upload_skips == 0
          ui.error "Uploaded #{upload_ok} #{'cookbook'.plural(upload_ok)} ok but #{upload_failures} #{'cookbook'.plural(upload_failures)} failed upload."
        elsif upload_skips > 0
          ui.error "Uploaded #{upload_ok} #{'cookbook'.plural(upload_ok)} ok but #{upload_skips} #{'cookbook'.plural(upload_skips)} were not included and #{upload_failures} #{'cookbook'.plural(upload_failures)} failed upload."
        end
      elsif upload_failures > 0 && upload_ok == 0
        ui.fatal "Failed to upload #{upload_failures} #{'cookbook'.plural(upload_failures)}."
        exit 1
      end
			# END Changes DLDInternet
    end

    unless version_constraints_to_update.empty?
      update_version_constraints(version_constraints_to_update) if config[:environment]
    end
  end

  def upload(cookbooks, justify_width)
    cookbooks.each do |cb|
      ui.step("Uploading #{cb.name.to_s.ljust(justify_width + 10)} [#{cb.version}]")
      check_for_broken_links!(cb)
      check_for_dependencies!(cb)
    end
    ::Chef::CookbookUploader.new(cookbooks, config[:cookbook_path], :force => config[:force]).upload_cookbooks
  rescue ::Chef::Exceptions::CookbookFrozen => e
    ui.error e
    raise
  end

end

