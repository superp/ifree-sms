# encoding: utf-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'ifree_sms', 'version')

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the ifree_sms plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the ifree_sms plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'BallotBox'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "ifree-sms"
    s.version = IfreeSms::VERSION.dup
    s.summary = "The IfreeSms gem for i-free sms provider"
    s.description = "The IfreeSms gem for i-free sms provider"
    s.email = "superp1987@gmail.com"
    s.homepage = "https://github.com/superp/ifree-sms"
    s.authors = ["Igor Galeta", "Pavlo Galeta"]
    s.files =  FileList["[A-Z]*", "{app,lib}/**/*"] - ["Gemfile"]
    #s.extra_rdoc_files = FileList["[A-Z]*"]
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
