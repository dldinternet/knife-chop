Gem::Specification.new do |s|
  s.name = "knife-chop"
  s.version = IO.read('VERSION')

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Christo De Lange"]
  s.date = "2014-07-01"
  s.description = "Knife plugin to assist with the upload and sync of Chef server assets like roles, environments and cookbooks allowing for multiple parts to be uploaded at once to multiple environments. Resources can be matched with regular expressions."
  s.email = "rubygems@dldinternet.com"
  s.executables = ["chop"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE.txt",
    "README.rdoc",
    "TODO.rdoc",
    "VERSION",
    "bin/chop",
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
    "lib/chef/knife/chop/version.rb",
    "lib/chef/knife/chop_base.rb",
    "lib/chef/knife/chop_translate.rb",
    "lib/chef/knife/chop_upload.rb",
    "lib/ruby-beautify/Gemfile",
    "lib/ruby-beautify/LICENSE",
    "lib/ruby-beautify/README.md",
    "lib/ruby-beautify/RELEASE.md",
    "lib/ruby-beautify/Rakefile",
    "lib/ruby-beautify/bin/rbeautify",
    "lib/ruby-beautify/lib/beautifier.rb",
    "lib/ruby-beautify/lib/ruby-beautify.rb",
    "lib/ruby-beautify/lib/ruby-beautify/block_end.rb",
    "lib/ruby-beautify/lib/ruby-beautify/block_matcher.rb",
    "lib/ruby-beautify/lib/ruby-beautify/block_start.rb",
    "lib/ruby-beautify/lib/ruby-beautify/config/ruby.rb",
    "lib/ruby-beautify/lib/ruby-beautify/language.rb",
    "lib/ruby-beautify/lib/ruby-beautify/line.rb",
    "lib/ruby-beautify/lib/ruby-beautify/version.rb",
    "lib/ruby-beautify/ruby-beautify.gemspec",
    "lib/ruby-beautify/spec/fixtures/ruby.yml",
    "lib/ruby-beautify/spec/rbeautify/block_matcher_spec.rb",
    "lib/ruby-beautify/spec/rbeautify/block_start_spec.rb",
    "lib/ruby-beautify/spec/rbeautify/config/ruby_spec.rb",
    "lib/ruby-beautify/spec/rbeautify/line_spec.rb",
    "lib/ruby-beautify/spec/rbeautify_spec.rb",
    "lib/ruby-beautify/spec/spec_helper.rb",
  ]
  s.homepage = "http://github.com/dldinternet/knife-chop"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Knife plugin to ease the upload and sync of Chef server assets"

  if s.respond_to? :specification_version
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency(%q<awesome_print>, [">= 1.2.0", "~> 1.2"])
      s.add_runtime_dependency(%q<colorize>, [">= 0.7.1", "~> 0.7"])
      s.add_runtime_dependency(%q<logging>, [">= 1.8.2", "~> 1.8"])
      s.add_runtime_dependency(%q<inifile>, [">= 2.0.2", "~> 2.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.8.1", "~> 1.8"])
      s.add_runtime_dependency(%q<mixlib-config>, [">= 2.1.0", "~> 2.1"])
      s.add_runtime_dependency(%q<chef>, [">= 11.12.0", "~> 11.12"])
      s.add_runtime_dependency(%q<safe_yaml>, [">= 0"])
    else
      s.add_dependency(%q<awesome_print>, [">= 1.2.0", "~> 1.2"])
      s.add_dependency(%q<colorize>, [">= 0.7.1", "~> 0.7"])
      s.add_dependency(%q<logging>, [">= 1.8.2", "~> 1.8"])
      s.add_dependency(%q<inifile>, [">= 2.0.2", "~> 2.0"])
      s.add_dependency(%q<json>, [">= 1.8.1", "~> 1.8"])
      s.add_dependency(%q<mixlib-config>, [">= 2.1.0", "~> 2.1"])
      s.add_dependency(%q<chef>, [">= 11.12.0", "~> 11.12"])
      s.add_dependency(%q<safe_yaml>, [">= 0"])
    end
  else
    s.add_dependency(%q<awesome_print>, [">= 1.2.0", "~> 1.2"])
    s.add_dependency(%q<colorize>, [">= 0.7.1", "~> 0.7"])
    s.add_dependency(%q<logging>, [">= 1.8.2", "~> 1.8"])
    s.add_dependency(%q<inifile>, [">= 2.0.2", "~> 2.0"])
    s.add_dependency(%q<json>, [">= 1.8.1", "~> 1.8"])
    s.add_dependency(%q<mixlib-config>, [">= 2.1.0", "~> 2.1"])
    s.add_dependency(%q<chef>, [">= 11.12.0", "~> 11.12"])
    s.add_dependency(%q<safe_yaml>, [">= 0"])
  end
end

