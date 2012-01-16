BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'yandex-tanker'
require 'awesome_print'

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
      # 1. For the whole project:
      #   1. Drop remote keysets not found locally.
      #   2. Create remote keysets for each local keyset if they don't exist.
      # 
      # 2. For each keyset:
      #   1. Load the en.lproj/KEYSET.strings file.
      #   2. Drop remote keys not found locally.
      #   3. Create remote keys for each local key is they don't exist.
      #   4. Pull remote keyset and write it in {en,ru,uk,tr}.lproj/KEYSET.strings.
      
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        strings_engine = Babelyoda::Engine::Strings.new
        strings = strings_engine.load_strings(filename)

        name = File.basename(filename, '.strings')
        spec.engine.replace(name, strings, spec.development_language)
      end
    end
    
    namespace :remote do
      
      desc "List remote keysets"
      task :list do
        ap spec.engine.list
      end
      
      desc "Drop remote keysets in the KEYSET environment variable, ex. KEYSET=k1,k2"
      task :drop do
        ENV['KEYSET'].split(',').each { |keyset| spec.engine.drop(keyset) }
      end
      
      desc "Create remote keysets in the KEYSET environment variable, ex. KEYSET=k1,k2"
      task :create do
        ENV['KEYSET'].split(',').each { |keyset| spec.engine.create(keyset) }
      end
    end
  
  end
end

def merge_to_previous_version(spec, lang, name, strings, opts = {})
  filename = strings_filename(spec, lang, name)
  engine = Babelyoda::Engine::Strings.new
  previous_version = engine.load_strings(filename)

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
