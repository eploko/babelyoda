require 'tmpdir'

require_relative 'localizable_resource'
require_relative 'strings'

module Babelyoda
  class StringsFile < LocalizableResource
    include Rake::DSL
    
    def initialize(folder, name, *args)
      super(folder, name, *args)
      @localizations = {}
      self.existing_localizations.each do |localization|
        @localizations[localization] = Babelyoda::Strings.read(localization_filename(localization))
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
      super + '[' + @localizations.keys.map{ |k| @localizations[k].size.to_s }.join(', ') + ']'
    end
  end
end
