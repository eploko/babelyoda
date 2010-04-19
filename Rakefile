require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "babelyoda"
    gem.summary = %Q{iPhone project localization made easy}
    gem.description = %Q{A simple utility to push/pull l10n resources of an iPhone project to/from the translators}
    gem.email = "andrey@subbotin.me"
    gem.homepage = "http://github.com/eploko/babelyoda"
    gem.authors = ["Andrey Subbotin"]
    gem.files =  FileList["[A-Z][A-Z]*", "bin/*", "lib/**/*"]
    gem.executables = ['babelyoda']
    gem.default_executable = ['babelyoda']
    #gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
