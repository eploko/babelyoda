require 'fileutils'
require 'yaml'

module Babelyoda
  class GitVersions

    def initialize
      @versions = load || {}
    end
    
    def exist?(filename)
      @versions.has_key?(filename)
    end
    
    def filename
      '.babelyoda/git_versions.yml'
    end
    
    def save!
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w') {|f| f.write(@versions.to_yaml) }
    end
    
    def [](filename)
      @versions[filename]
    end
    
    def []=(filename, value)
      @versions[filename] = value
    end
    
  private
    
    def load
      @versions = YAML::load_file(filename) if File.exist?(filename)
    end
        
  end
end
