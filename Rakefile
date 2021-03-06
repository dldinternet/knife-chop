# encoding: utf-8

require 'rubygems'
require 'rubygems/package_task'
require 'bundler'
require 'rake'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end


Dir[File.expand_path("../*gemspec", __FILE__)].reverse.each do |gemspec_path|
	gemspec = eval(IO.read(gemspec_path))
	Gem::PackageTask.new(gemspec).define
end

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

require 'rake'

require 'rubygems/tasks'
Gem::Tasks.new

require File.dirname(__FILE__) + '/lib/chef/knife/chop/version'
desc "Commit it, push it, build it, tag it and ship it"
task :ship => [:clobber_package,:clobber_rdoc,:gem] do
	sh("git add -A")
	sh("git commit -m 'Ship #{::Knife::Chop::VERSION}'")
	sh("git tag #{::Knife::Chop::VERSION}")
	sh("git push origin --tags")
	Dir[File.expand_path("../pkg/*.gem", __FILE__)].reverse.each do |built_gem|
		sh("gem push #{built_gem}")
	end
end

desc "Build it, tag it and ship it"
task :push => [:clobber_package,:clobber_rdoc,:gem] do
	sh("git tag #{::Knife::Chop::VERSION}")
	sh("git push origin --tags")
	Dir[File.expand_path("../pkg/*.gem", __FILE__)].reverse.each do |built_gem|
		sh("gem push #{built_gem}")
	end
end

