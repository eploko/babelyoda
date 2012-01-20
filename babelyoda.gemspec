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
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec",       '~> 2.8', '>= 2.8.0'
  s.add_runtime_dependency "awesome_print",   '~> 1.0', '>= 1.0.2'
  s.add_runtime_dependency "rake",            '~> 0.9', '>= 0.9.2.2'
  s.add_runtime_dependency "active_support",  '~> 3.0', '>= 3.0.0'
  s.add_runtime_dependency "rchardet19",      '~> 1.3', '>= 1.3.5'
  s.add_runtime_dependency "builder",         '~> 3.0', '>= 3.0.0'
  s.add_runtime_dependency "nokogiri",        '~> 1.5', '>= 1.5.0'
  s.add_runtime_dependency "term-ansicolor",  '~> 1.0', '>= 1.0.7'
  s.add_runtime_dependency "log4r",           '~> 1.1.7'
end
