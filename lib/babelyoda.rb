BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'awesome_print'

require_relative 'babelyoda/genstrings'
require_relative 'babelyoda/ibtool'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/localization_key'
require_relative 'babelyoda/localization_value'
require_relative 'babelyoda/rake'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/tanker'
require_relative 'babelyoda/xib'

namespace :babelyoda do
  
  file 'Babelfile' do
    Babelyoda::Specification.generate_default_babelfile
  end
  
  desc "Create a basic bootstrap Babelfile"
  task :init => 'Babelfile' do
  end
  
  Babelyoda::Rake.spec do |spec|

    desc "Extract strings from sources"
    task :extract_strings do
      puts "Extracting strings from sources..."
      dev_lang = spec.development_language
      Babelyoda::Genstrings.run(spec.source_files, dev_lang) do |keyset|
        old_strings_filename = strings_filename(keyset.name, dev_lang)
        old_strings = Babelyoda::Strings.new(old_strings_filename, dev_lang).read
        old_strings.merge!(keyset)
        old_strings.save!
        puts "  #{old_strings_filename}: #{old_strings.keys.size} keys"
      end
    end
    
    desc "Extract strings from XIBs"
    task :extract_xib_strings do
      puts "Extracting .strings from XIBs..."
      spec.xib_files.each do |xib_filename|
        xib = Babelyoda::Xib.new(xib_filename, spec.development_language)
        next unless xib.extractable?(spec.development_language)
        keyset = xib.strings
        next if keyset.empty?
        puts "  #{xib_filename} => #{xib.strings_filename}"
        Babelyoda::Strings.save_keyset(keyset, xib.strings_filename, spec.development_language)
      end
    end
    
    desc "Create remote keysets for local keysets"
    task :create_keysets => [:extract_strings, :extract_xib_strings] do
      # Create remote keysets for each local keyset if they don't exist.
      puts "Creating remote keysets for local keysets..."
      remote_keyset_names = spec.engine.list
      spec.strings_files.each do |filename|
        keyset_name = Babelyoda::Keyset.keyset_name(filename)
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
      spec.strings_files.each do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language).read!
        puts "  Processing keyset: #{strings.name}"
        remote_keyset = spec.engine.load_keyset(strings.name)
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
      spec.strings_files.each do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language).read!
        puts "  Processing keyset: #{strings.name}"
        remote_keyset = spec.engine.load_keyset(strings.name, nil, :unapproved)
        result = remote_keyset.merge!(strings, preserve: true)
        remote_keyset.ensure_languages!(spec.all_languages)
        spec.engine.replace(remote_keyset)
        puts "    New keys: #{result[:new]} Updated keys: #{result[:updated]}"
      end
    end
    
    desc "Fetches remote strings and merges them down into local .string files"
    task :fetch_strings do
      puts "Fetching remote translations..."
      spec.strings_files.each do |filename|
        keyset_name = Babelyoda::Keyset.keyset_name(filename)
        remote_keyset = spec.engine.load_keyset(keyset_name, nil, :unapproved, true)
        remote_keyset.drop_empty!
        spec.all_languages.each do |language|
          keyset_filename = strings_filename(keyset_name, language)
          Babelyoda::Strings.save_keyset(remote_keyset, keyset_filename, language)
          puts "  #{keyset_filename}"
        end
      end
    end

    desc "Pull remote translations"
    task :pull => :fetch_strings do      
    end
    
    namespace :remote do
      
      desc "List remote keysets"
      task :list do
        ap spec.engine.list
      end
      
      desc "Drop remote keysets in KEYSETS"
      task :drop_keysets do
        if ENV['KEYSETS']
          keysets = ENV['KEYSETS'].split(',')
          if keysets.include?('*')
            keysets = spec.engine.list
            puts "Dropping ALL keysets: #{keysets}"
          else
            puts "Dropping keysets: #{keysets}"            
          end
          keysets.each do |keyset_name|
            puts "  Dropping: #{keyset_name}"
            keyset = Babelyoda::Keyset.new(keyset_name)
            key = Babelyoda::LocalizationKey.new("Dummy", "Dummy")
            value = Babelyoda::LocalizationValue.new(:en, "Dummy")
            key << value
            keyset.merge_key!(key)
            spec.engine.replace(keyset)
          end
          puts "All done!"
        else
          puts "Please provide keyset names to drop in the KEYSET environment variable. Separate by commas. Use * for ALL."
        end
      end

    end
  
  end
end

def strings_filename(keyset_name, lang)
  if keyset_name.match(/\//)
    File.join(File.dirname(keyset_name), "#{lang}.lproj", "#{File.basename(keyset_name)}.strings")
  else
    File.join("#{lang}.lproj", "#{keyset_name}.strings")
  end
end
