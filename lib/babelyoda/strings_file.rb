require_relative 'localizable_resource'

module Babelyoda
  class StringsFile < LocalizableResource
    
    def initialize(folder, name, *args)
      super(folder, name, *args)
      self.existing_localizations.each do |localization|
        puts "EXISTING LOCALIZATION: #{localization}"
      end
    end
    
    def import_source_strings(source_file)
      return if uptodate?([source_file])
      puts "genstrings #{source_file}"
    end
  end
end
