require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  test_files = FileList['test/**/*_test.rb']
  t.test_files = test_files
  t.verbose = true
end