# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: knife-chop 0.0.10 ruby lib

Gem::Specification.new do |s|
  s.name = "knife-chop"
  s.version = "0.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christo De Lange"]
  s.date = "2013-10-30"
  s.description = "Knife plugin to assist with the upload and sync of Chef server assets like roles, environments and cookbooks allowing for multiple parts to be uploaded at once to multiple environments. Resources can be matched with regular expressions."
  s.email = "opscode@dldinternet.com"
  s.executables = ["chop"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".ruby-gemset",
    ".ruby-version",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/chop",
    "knife-chop.gemspec",
    "lib/chef/knife/chop/chef_data_bag_item.rb",
    "lib/chef/knife/chop/chef_environment.rb",
    "lib/chef/knife/chop/chef_knife.rb",
    "lib/chef/knife/chop/chef_part.rb",
    "lib/chef/knife/chop/chef_role.rb",
    "lib/chef/knife/chop/cookbook_upload.rb",
    "lib/chef/knife/chop/data_bag_from_file.rb",
    "lib/chef/knife/chop/environment_from_file.rb",
    "lib/chef/knife/chop/errors.rb",
    "lib/chef/knife/chop/logging.rb",
    "lib/chef/knife/chop/role_from_file.rb",
    "lib/chef/knife/chop/translate.rb",
    "lib/chef/knife/chop/translate/eden.rb",
    "lib/chef/knife/chop/translate/rbeautify.rb",
    "lib/chef/knife/chop/ui.rb",
    "lib/chef/knife/chop_base.rb",
    "lib/chef/knife/chop_translate.rb",
    "lib/chef/knife/chop_upload.rb",
    "lib/knife-chop/version.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/dldinternet/knife-chop"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.5"
  s.summary = "Knife plugin to ease the upload and sync of Chef server assets"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<rake>, ["~> 10.1"])
      s.add_development_dependency(%q<sdoc>, ["~> 0.3"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.8"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<rake>, ["~> 10.1"])
      s.add_dependency(%q<sdoc>, ["~> 0.3"])
      s.add_dependency(%q<jeweler>, [">= 1.8.8"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<rake>, ["~> 10.1"])
    s.add_dependency(%q<sdoc>, ["~> 0.3"])
    s.add_dependency(%q<jeweler>, [">= 1.8.8"])
  end
end

