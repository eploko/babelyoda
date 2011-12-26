module Babelyoda
  class LocalizableResource
    attr_reader :folder
    attr_reader :name
    attr_reader :development_language
    attr_reader :localization_languages
    
    def initialize(folder, name, development_language = :en, *args)
      super(*args)
      @folder, @name, @development_language = folder, name, development_language
      @localization_languages = []
    end
    
    def existing_localizations
      Dir.glob(localization_filename('*')).map do |fn|
        File.split(File.split(fn)[0])[1].match(/^(.*)\.lproj$/)[1].to_sym
      end
    end
    
    def localization_filename(localization)
      File.join(self.folder, "#{localization}.lproj", self.name)
    end
    
    def development_localization_filename
      localization_filename(self.development_language)
    end
    
    def all_languages
      [self.development_language, *self.localization_languages]
    end
    
    def uptodate?(src_files)
      FileUtils.uptodate?(development_localization_filename, src_files)
    end
  end
end
