# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "noscript/version"

Gem::Specification.new do |s|
  s.name        = "noscript"
  s.version     = Noscript::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josep M. Bach"]
  s.email       = ["josep.m.bach@gmail.com"]
  s.homepage    = "http://github.com/txus/noscript"
  s.summary     = %q{An object-oriented scripting language written in pure Ruby.}
  s.description = %q{An object-oriented scripting language written in pure Ruby.}

  s.rubyforge_project = "noscript"

  s.add_development_dependency 'rexical'
  s.add_development_dependency 'racc'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
