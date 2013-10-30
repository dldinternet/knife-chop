# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'knife-chop/version'

Gem::Specification.new do |s|
  s.name         = 'knife-chop'
  s.version      = Knife::Chop::VERSION
  s.authors      = ['Christo De Lange']
  s.email        = ['opscode@dldinternet.com']
  s.homepage     = 'https://github.com/dldinternet/knife-chop'
  s.summary      = %q{Upload and Translate Support for Chef\'s Knife Command}
  s.description  = s.summary
  s.license      = 'Apache 2.0'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'fog',           '~> 1.6'
  s.add_dependency 'chef',          '>= 11.6.2'
  s.add_dependency 'mixlib-config', '= 1.1.2'
  s.add_dependency 'knife-windows', '>= 0.5.12'
  s.add_dependency 'colorize'
  s.add_dependency 'inifile'
  s.add_dependency 'awesome_print'
  s.add_dependency 'json'
  s.add_dependency 'nokogiri', '~> 1.5.10'
  s.add_dependency 'sorcerer'

  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rake',  '~> 10.1'
  s.add_development_dependency 'sdoc',  '~> 0.3'
  s.add_development_dependency 'jeweler', '>= 1.8.8'

  s.require_paths = ['lib']
end
