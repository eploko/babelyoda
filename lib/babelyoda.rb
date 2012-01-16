BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'awesome_print'

require_relative 'babelyoda/genstrings'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/rake'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/tanker'

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
      dev_lang = spec.development_language
      Babelyoda::Genstrings.run(spec.source_files, dev_lang) do |keyset|
        old_strings_filename = strings_filename(spec, dev_lang, keyset.name)
        old_strings = Babelyoda::Strings.new(old_strings_filename, dev_lang).read
        old_strings.merge!(keyset)
        old_strings.save!
        puts "#{old_strings_filename}: #{old_strings.keys.size} keys"
      end
    end
    
    desc "Create remote keysets for local keysets"
    task :create_keysets => :genstrings do
      # Create remote keysets for each local keyset if they don't exist.
      puts "Creating remote keysets for local keysets..."
      remote_keyset_names = spec.engine.list
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        keyset_name = File.basename(filename, '.strings')
        if remote_keyset_names.include?(keyset_name)
          puts "  Tanker: An existing keyset found: #{keyset_name}"
          next 
        end
        spec.engine.create(keyset_name)
        puts "  Tanker: Created NEW keyset: #{keyset_name}"
      end
    end
    
    desc "Drops remote keys not found in local keysets"
    task :drop_orphan_keys => :create_keysets do
      puts "Dropping orphan keys..."
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language).read!
        keyset_name = File.basename(filename, '.strings')
        puts "  Processing keyset: #{keyset_name}"
        remote_keyset = spec.engine.load_keyset(keyset_name)
        keys_to_drop = []
        remote_keyset.keys.each_value do |key|
          unless strings.keys.has_key?(key.id)
            keys_to_drop << key.id 
            puts "    Found orphan key: #{key.id}"
          end
        end
        keys_to_drop.each do |key|
          remote_keyset.keys.delete(key)
        end
        spec.engine.replace(remote_keyset)
        puts "    Dropped keys: #{keys_to_drop.size}"
      end
    end
    
    desc "Pushes resources to the translators"
    task :push => :drop_orphan_keys do
      puts "Pushing local keys to the remote..."
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language).read!
        keyset_name = File.basename(filename, '.strings')
        puts "  Processing keyset: #{keyset_name}"
        remote_keyset = spec.engine.load_keyset(keyset_name, nil, :unapproved)
        result = remote_keyset.merge!(strings, preserve: true)
        remote_keyset.ensure_languages!(spec.all_languages)
        spec.engine.replace(remote_keyset)
        puts "    New keys: #{result[:new]} Updated keys: #{result[:updated]}"
      end
    end

    desc "Pull remote translations"
    task :pull do      
      puts "Pulling remote transaltions..."
      Dir.glob(File.join(spec.resources_folder, "#{spec.development_language}.lproj", '*.strings')).each do |filename|
        keyset_name = File.basename(filename, '.strings')
        remote_keyset = spec.engine.load_keyset(keyset_name, nil, :unapproved, true)
        remote_keyset.drop_empty!
        spec.all_languages.each do |language|
          filename = strings_filename(spec, language, keyset_name)
          Babelyoda::Strings.save_keyset(remote_keyset, filename, language)
          puts "  #{filename}"
        end
      end
    end
    
    namespace :remote do
      
      desc "List remote keysets"
      task :list do
        ap spec.engine.list
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
