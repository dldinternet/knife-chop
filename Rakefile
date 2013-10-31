# encoding: utf-8

require 'rubygems'
require 'rubygems/package_task'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'


Dir[File.expand_path("../*gemspec", __FILE__)].reverse.each do |gemspec_path|
	gemspec = eval(IO.read(gemspec_path))
	Gem::PackageTask.new(gemspec).define
end

require File.dirname(__FILE__) + '/lib/chef/knife/chop/version'
desc "Build it, tag it and ship it"
task :ship => [:clobber,:gem] do
	sh("git add -A")
	sh("git commit -m 'Ship #{::Knife::Chop::VERSION}'")
	sh("git tag #{::Knife::Chop::VERSION}")
	sh("git push origin --tags")
	Dir[File.expand_path("../pkg/*.gem", __FILE__)].reverse.each do |built_gem|
		sh("gem push #{built_gem}")
	end
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "knife-chop"
  gem.homepage = "http://github.com/dldinternet/knife-chop"
  gem.license = "MIT"
  gem.summary = %Q{Knife plugin to ease the upload and sync of Chef server assets}
  gem.description = %Q{Knife plugin to assist with the upload and sync of Chef server assets like roles, environments and cookbooks allowing for multiple parts to be uploaded at once to multiple environments. Resources can be matched with regular expressions.}
  gem.email = "rubygems@dldinternet.com"
  gem.authors = ["Christo De Lange"]
  # dependencies defined in Gemfile

  gem.files.exclude '.document'
  gem.files.exclude '.rspec'
  gem.files.exclude '.ruby-*'
  gem.files.exclude '.idea/**'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "knife-chop #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

