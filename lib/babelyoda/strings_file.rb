require 'tmpdir'

require_relative 'localizable_resource'
require_relative 'strings'

module Babelyoda
  class StringsFile < LocalizableResource
    include Rake::DSL
    
    attr_reader :localizations
    
    def initialize(folder, name, *args)
      super(folder, name, *args)
      @localizations = {}
    end
    
    def self.read(folder, name, *args)
      result = new(folder, name, *args)
      result.read
      return result
    end
    
    def read
      self.existing_localizations.each do |localization|
        @localizations[localization] = Babelyoda::Strings.read(localization_filename(localization))
      end
    end
    
    def write
      @localizations.each_pair do |key, localization|
        localization.write(localization_filename(key))
      end
    end
    
    def import_source_strings(source_file)
      return if up_to_date?([source_file])
      Dir.mktmpdir do |dir|
        # use the directory...
        sh "genstrings #{source_file} -o #{dir}"
        Dir.glob(File.join(dir, '*')).each do |f|
          puts "FILE: #{f}"
        end
      end
    end
    
    def to_s
      super + '[' + self.keys.size.to_s + ']'
    end
    
    def keys
      result = @localizations.keys.map{ |k| @localizations[k].keys }.flatten!
      result.uniq!.sort! if result
      return result || []
    end
    
    def <<(other_file)
      other_file.localizations.each_pair do |key, value|
        @localizations[key] = Babelyoda::Strings.new unless @localizations.has_key?(key)
        @localizations[key] << value
      end
    end
  end
end
