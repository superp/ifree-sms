# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ifree_sms/version"

Gem::Specification.new do |s|
  s.name = "ifree-sms"
  s.version = IfreeSms::VERSION.dup
  s.platform = Gem::Platform::RUBY 
  s.summary = "The IfreeSms gem for i-free sms provider"
  s.description = "The IfreeSms gem for i-free sms provider"
  s.authors = ["Igor Galeta", "Pavlo Galeta"]
  s.email = "superp1987@gmail.com"
  s.rubyforge_project = "sunrise-core"
  s.homepage = "https://github.com/superp/ifree-sms"
  
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.test_files = Dir["{spec}/**/*"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency(%q<curb>, ["~> 0.7.15"])
  s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
  s.add_runtime_dependency(%q<activemodel>, [">= 0"])
end
