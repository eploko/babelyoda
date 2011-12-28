BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require_relative 'babelyoda/engine'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/rake'

namespace :babelyoda do
  
  file 'Babelfile' do
    Babelyoda::Specification.generate_default_babelfile
  end
  
  desc "Create a basic bootstrap Babelfile"
  task :init => 'Babelfile' do
  end
  
  # Babelyoda::Rake.spec do |spec|
  #   
  #   STRINGS_FILE = Babelyoda::StringsFile.read(spec.resources_folder, 'Localizable.strings', spec.development_language)
  #   STRINGS_FILE.localization_languages.push(*spec.localization_languages)
  #   DEV_LOCALIZATION_STRINGS_FILENAME = STRINGS_FILE.development_localization_filename
  #   
  #   namespace :strings do
  #     
  #     file DEV_LOCALIZATION_STRINGS_FILENAME => spec.source_files do
  #       spec.source_files.each do |f|
  #         STRINGS_FILE.import_source_strings(f)
  #       end
  #     end
  #           
  #     desc "Extract strings with genstrings"
  #     task :extract => DEV_LOCALIZATION_STRINGS_FILENAME do
  #     end
  #   
  #     spec.localization_languages.each do |lang|
  #       file STRINGS_FILE.localization_filename(lang) => DEV_LOCALIZATION_STRINGS_FILENAME do
  #       end
  #       
  #       task :extract => STRINGS_FILE.localization_filename(lang)
  #     end    
  #   end
  #   
  #   desc "Pushes resources to the translators"
  #   task :push => 'strings:extract' do
  #     project = Babelyoda::Project.new(spec)
  #     project.push
  #   end
  # 
  # end
end
