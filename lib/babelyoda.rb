BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require_relative 'babelyoda/engine'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/tools'
require_relative 'babelyoda/rake'

namespace :babelyoda do
  
  file 'Babelfile' do
    Babelyoda::Specification.generate_default_babelfile
  end
  
  desc "Create a basic bootstrap Babelfile"
  task :init => 'Babelfile' do
  end
  
  Babelyoda::Rake.spec do |spec|

    desc "Extract strings with genstrings"
    task :genstrings do
      Babelyoda::Tools::Genstrings.run(spec.source_files) do |name, strings|
        merge_to_previous_version(spec, spec.development_language, name, strings)
        spec.localization_languages.each do |lang|
          merge_to_previous_version(spec, lang, name, strings)
        end
      end
    end
        
    desc "Pushes resources to the translators"
    task :push => :genstrings do
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        puts "FILE TO PUSH: #{filename}"
        # strings = Babelyoda::Strings.read(filename)
      end
    end
  
  end
end

def merge_to_previous_version(spec, lang, name, strings, opts = {})
  filename = strings_filename(spec, lang, name)
  previous_version = Babelyoda::Strings.read(filename)

  engine = Babelyoda::Engine::Strings.new

  if previous_version
    previous_version.merge!(strings, opts)
    previous_version.purge_keys_not_in!(strings)
    engine.save_strings(previous_version, filename)
  else 
    engine.save_strings(strings, filename)
  end
end

def strings_filename(spec, lang, name)
  File.join(spec.resources_folder, "#{lang}.lproj", "#{name}.strings")
end
