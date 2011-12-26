require 'erb'

require_relative 'specification_loader'

module Babelyoda
	class Specification
		include Babelyoda::SpecificationLoader

    attr_accessor :name
    attr_accessor :development_language
    attr_accessor :localization_languages
    attr_accessor :engine
    attr_accessor :source_files
    attr_accessor :resources_folder
    
    FILENAME = 'Babelfile'
    
    def self.generate_default_babelfile
      template_file_name = File.join(BABELYODA_PATH, 'templates', 'Babelfile.erb')
      template = File.read(template_file_name)
      File.open(FILENAME, "w+") do |f|
        f.write(ERB.new(template).result())
      end
    end
    
    def self.load
      trace_spec = @spec.nil? && ::Rake.application.options.trace
	    @spec ||= load_from_file(filename = FILENAME)
	    @spec.dump if trace_spec && @spec
	    return @spec
    end
    
    def localized_strings_filename(language)
      File.expand_path(File.join(self.resources_folder, "#{language.to_s}.lproj", 'Localizable.strings'))
    end
    
  end
end
