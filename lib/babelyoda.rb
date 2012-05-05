BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'awesome_print'
require 'fileutils'

require_relative 'babelyoda/genstrings'
require_relative 'babelyoda/git'
require_relative 'babelyoda/ibtool'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/localization_key'
require_relative 'babelyoda/localization_value'
require_relative 'babelyoda/logger'
require_relative 'babelyoda/rake'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/tanker'
require_relative 'babelyoda/xib'

desc "Do a full localization cycle: push new strings, get translations and merge them"
task :babelyoda => ['babelyoda:push', 'babelyoda:pull'] do
end

namespace :babelyoda do
  
  file 'Babelfile' do
    Babelyoda::Specification.generate_default_babelfile
  end
  
  desc "Create a basic bootstrap Babelfile"
  task :init => 'Babelfile' do
  end
  
  Babelyoda::Rake.spec do |spec|
    
    desc "Extract strings from sources. Use PRESERVE=1 so that orphan keys don't get dropped."
    task :extract_strings do
      spec.scm.transaction("[Babelyoda] Extract strings from sources") do 
        $logger.info "Extracting strings from sources..."
        dev_lang = spec.development_language
        Babelyoda::Genstrings.run(spec.source_files, dev_lang) do |keyset|
          keyset_name = File.join(spec.resources_folder, keyset.name)
          old_strings_filename = strings_filename(keyset_name, dev_lang)
          old_strings = Babelyoda::Strings.new(old_strings_filename, dev_lang)
          old_strings.read if ENV['PRESERVE'].to_i == 1
          old_strings.merge!(keyset)
          old_strings.save!
          $logger.debug "#{old_strings_filename}: #{old_strings.keys.size} keys"
        end
      end
    end
    
    desc "Extract strings from XIBs"
    task :extract_xib_strings do
      spec.scm.transaction("[Babelyoda] Extract strings from XIBs") do 
        $logger.info "Extracting .strings from XIBs..."
        spec.xib_files.each do |xib_filename|
          xib = Babelyoda::Xib.new(xib_filename, spec.development_language)
          next unless xib.extractable?(spec.development_language)
          keyset = xib.strings
          unless keyset.empty?
            $logger.debug "#{xib_filename} => #{xib.strings_filename}"
            Babelyoda::Strings.save_keyset(keyset, xib.strings_filename, spec.development_language)
          end
        end
      end
    end
    
    desc "Extracts localizable strings into the corresponding .strings files"
    task :extract => [:extract_strings, :extract_xib_strings] do
    end
    
    desc "Drops empty local keysets"
    task :drop_empty_strings do
      spec.scm.transaction("[Babelyoda] Drop empty .strings files") do 
        $logger.info "Dropping empty .strings files..."
        files_to_drop = []
        spec.strings_files.each do |filename|
          strings = Babelyoda::Strings.new(filename, spec.development_language).read!
          if strings.empty?
            files_to_drop << filename
            spec.localization_languages.each do |language|
              localized_filename = File.localized(filename, language)
              files_to_drop << localized_filename if File.exist?(localized_filename)
            end
          end
        end
        files_to_drop.each do |filename|
          $logger.info "REMOVED empty file: #{filename}"
          FileUtils.rm filename
        end
      end
    end
    
    desc "Create remote keysets for local keysets"
    task :create_keysets => [:extract, :drop_empty_strings] do
      $logger.info "Creating remote keysets for local keysets..."
      remote_keyset_names = spec.engine.list
      spec.strings_files.each do |filename|
        keyset_name = Babelyoda::Keyset.keyset_name(filename)
        if remote_keyset_names.include?(keyset_name)
          $logger.debug "Tanker: An existing keyset found: #{keyset_name}"
          next 
        end
        strings = Babelyoda::Strings.new(filename, spec.development_language).read
        unless strings.empty?
          spec.engine.create(keyset_name)
          $logger.debug "Tanker: Created NEW keyset: #{keyset_name}"
        end
      end
    end

    desc "Drops remote keysets not found locally"
    task :drop_orphan_keysets => :create_keysets do
      $logger.info "Dropping orphan keysets..."
      local_keysets = spec.strings_files.map do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language)
        strings.name        
      end
      count = 0
      spec.engine.list.each do |remote_keyset_name|
        unless local_keysets.include?(remote_keyset_name)
          $logger.debug "Dropping keyset: #{remote_keyset_name}"
          spec.engine.drop_keyset!(remote_keyset_name)
          count += 1
        end
      end
      $logger.info "Dropped keysets: #{count}" if count > 0
    end
    
    desc "Drops remote keys not found in local keysets"
    task :drop_orphan_keys => :create_keysets do
      $logger.info "Dropping orphan keys..."
      spec.strings_files.each do |filename|
        strings = Babelyoda::Strings.new(filename, spec.development_language).read!
        $logger.debug "Processing keyset: #{strings.name}"
        remote_keyset = spec.engine.load_keyset(strings.name)
        original_keys_size = remote_keyset.keys.size
        remote_keyset.keys.delete_if do |key, value|
          unless strings.keys.has_key?(key)
            $logger.debug "Found orphan key: #{key}"
            true
          else
            false
          end
        end
        next if original_keys_size == remote_keyset.keys.size
        unless remote_keyset.empty?
          $logger.debug "Keys removed: #{original_keys_size - remote_keyset.keys.size}, keyset REPLACED."
          spec.engine.replace(remote_keyset)
        else
          $logger.debug "All keys removed: keyset DELETED."
          spec.engine.drop_keyset!(remote_keyset.name)
        end
      end
    end
    
    desc "Pushes resources to the translators. Use LANGS to specify languages to push. Defaults to '#{spec.development_language}'."
    task :push => [:drop_orphan_keysets, :drop_orphan_keys] do
      langs = [ spec.development_language ]
      if ENV['LANGS']
        if ENV['LANGS'] == '*'
          langs = spec.all_languages
        else
          langs = ENV['LANGS'].split(',').map { |s| s.to_sym }
        end
      end
      $logger.info "Pushing local keys for '#{langs.join(', ')}' to the remote..."
      spec.strings_files.each do |filename|
        local_keyset = Babelyoda::Strings.new(filename, spec.development_language).read!
        $logger.debug "Processing keyset: #{local_keyset.name}"
        
        langs.each do |lang|
          next if lang == spec.development_language
          fn = strings_filename(local_keyset.name, lang)
          next unless File.exist?(fn)
          strings = Babelyoda::Strings.new(fn, lang).read!
          local_keyset.merge!(strings, preserve: true)
        end
        
        remote_keyset = spec.engine.load_keyset(local_keyset.name, nil, :unapproved)
        result = remote_keyset.merge!(local_keyset, preserve: true, plain_text_keys: spec.plain_text_keys)
        remote_keyset.ensure_languages!(spec.all_languages)
        if result[:new] > 0 || result[:updated] > 0
          langs.each do |lang|
            spec.engine.replace(remote_keyset, lang)
          end
          $logger.debug "New keys: #{result[:new]} Updated keys: #{result[:updated]}"
        end
      end
    end
    
    desc "Fetches remote strings and merges them down into local .string files"
    task :fetch_strings do
      spec.scm.transaction("[Babelyoda] Merge in remote translations") do 
        $logger.info "Fetching remote translations..."
        spec.strings_files.each do |filename|
          keyset_name = Babelyoda::Keyset.keyset_name(filename)
          remote_keyset = spec.engine.load_keyset(keyset_name, nil, :unapproved)
          remote_keyset.drop_empty!
          spec.all_languages.each do |language|
            keyset_filename = strings_filename(keyset_name, language)
            Babelyoda::Strings.save_keyset(remote_keyset, keyset_filename, language)
            $logger.debug "#{keyset_filename}"
          end
        end
      end
    end
    
    desc "Incrementally localizes XIB files"
    task :localize_xibs do
      spec.scm.transaction("[Babelyoda] Localize XIB files") do 
        $logger.info "Translating XIB files..."
        spec.xib_files.each do |filename|
          xib = Babelyoda::Xib.new(filename, spec.development_language)
          if xib.localizable?
            xib.import_strings(spec.scm)
            spec.localization_languages.each do |language|
              xib.localize_incremental(language, spec.scm)
            end
          else
            $logger.warn "#{filename} has no localizable resources. No localization needed."
          end
        end
      end
      
      spec.scm.transaction("[Babelyoda] Update XIB SHA1 version refs") do 
        spec.xib_files.each do |filename|
          spec.scm.store_version!(filename)
        end
      end
    end

    desc "Pull remote translations"
    task :pull => [:fetch_strings, :localize_xibs] do
    end
    
    desc "Verifies all local translations are present"
    task :verify do
      combined_keyset = Babelyoda::Keyset.new('babelyoda.verify')
      spec.strings_files.each do |filename|
        dev_lang_strings = Babelyoda::Strings.new(filename, spec.development_language).read
        combined_keyset.merge!(dev_lang_strings)
        spec.localization_languages.each do |language|
          lang_strings = Babelyoda::Strings.new(File.localized(filename, language), language).read
          combined_keyset.merge!(lang_strings)
        end
      end
      combined_keyset.drop_empty!
      
      count = {}
      spec.all_languages.each { |lang| count[lang.to_sym] = 0}
      
      combined_keyset.keys.each_value do |key|
        spec.all_languages.each do |lang|
          count[lang.to_sym] += 1 if key.values.has_key?(lang.to_sym)
        end
      end

      total_count = count[spec.development_language.to_sym]
      $logger.info "#{spec.development_language}: #{total_count} keys"
      
      all_found = true
      spec.localization_languages.each do |language|
        lang_count = count[language.to_sym]
        missing_count = total_count - lang_count
        if missing_count > 0
          $logger.error "#{language}: #{lang_count} keys (#{missing_count} translations missing)"
          all_found = false
        end
      end
      exit 1 unless all_found
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
            $logger.info "Dropping ALL keysets: #{keysets}"
          else
            $logger.info "Dropping keysets: #{keysets}"            
          end
          keysets.each do |keyset_name|
            $logger.debug "Dropping: #{keyset_name}"
            spec.engine.drop_keyset!(keyset_name)
          end
        else
          $logger.error "Please provide keyset names to drop in the KEYSET environment variable. " +
                        "Separate by commas. Use * for ALL."
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
