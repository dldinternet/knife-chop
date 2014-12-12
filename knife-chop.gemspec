Gem::Specification.new do |s|
  s.name = "knife-chop"
  s.version = IO.read('VERSION')

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Christo De Lange"]
  s.description = "Knife plugin to assist with the upload and sync of Chef server assets like roles, environments and cookbooks allowing for multiple parts to be uploaded at once to multiple environments. Resources can be matched with regular expressions."
  s.email = "rubygems@dldinternet.com"
  s.executables = ["chop"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.homepage = "http://github.com/dldinternet/knife-chop"
  s.licenses = ["MIT"]
  s.summary = "Knife plugin to ease the upload and sync of Chef server assets"

  s.add_dependency %q<awesome_print>, [">= 1.2.0", "~> 1.2"]
  s.add_dependency %q<colorize>, [">= 0.7.1", "~> 0.7"]
  s.add_dependency %q<logging>, [">= 1.8.2", "~> 1.8"]
  s.add_dependency %q<inifile>, [">= 2.0.2", "~> 2.0"]
  s.add_dependency %q<json>, [">= 1.8.1", "~> 1.8"]
  s.add_dependency %q<mixlib-config>, [">= 2.1.0", "~> 2.1"]
  s.add_dependency %q<chef>, [">= 11.16.0", "~> 11.16"]
  s.add_dependency %q<safe_yaml>, [">= 0"]

  s.add_development_dependency 'rubygems-tasks', '~> 0.2'

end

