# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "babelyoda/version"

Gem::Specification.new do |s|
  s.name        = "babelyoda"
  s.version     = Babelyoda::VERSION
  s.authors     = ["Andrey Subbotin"]
  s.email       = ["andrey@subbotin.me"]
  s.homepage    = "http://github.com/eploko/babelyoda"
  s.summary     = "Xcode project localization made easy"
  s.description = "A simple utility to push/pull l10n resources of an Xcode project to/from the translators"

  s.rubyforge_project = "babelyoda"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "awesome_print"
  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "active_support"
  s.add_runtime_dependency "rchardet19"
  s.add_runtime_dependency "builder"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "term-ansicolor"
end
