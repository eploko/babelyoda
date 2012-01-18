require 'fileutils'

require_relative 'file'
require_relative 'ibtool'

module Babelyoda
  class Xib
    attr_reader :filename
    attr_reader :language
    
    def initialize(filename, language)
      @filename, @language = filename, language
    end
    
    def extractable?(development_language)
      lproj_part = File.lproj_part(@filename)
      (!lproj_part.nil?) && lproj_part == "#{development_language}.lproj"
    end
    
    def dirname
      File.dirname(@filename)
    end
    
    def basename
      File.basename(File.split(@filename)[1], '.xib')
    end
    
    def resourced?
      !File.lproj_part(@filename).nil?
    end
    
    def resource!
      raise "The XIB is already in a resource folder: #{@filename}" unless File.lproj_part(@filename).nil?
      mv(File.localized(@filename, @language))
    end
    
    def mv(new_filename)
      FileUtils.mkdir_p(File.dirname(new_filename))
      FileUtils.mv(@filename, new_filename)
      @filename = new_filename
    end
    
    def strings?
      !strings.empty?
    end
    
    def strings
      Babelyoda::Ibtool.extract_strings(@filename, @language)
    end
    
    def localize(language, scm)
      puts "Localizing #{filename} => #{File.localized(filename, language)}..."
      assert_localization_target(language)
      strings_fn = strings_filename(language)
      $logger.error "No strings file found: #{strings_fn}" unless File.exist?(strings_fn)
      Babelyoda::Ibtool.localize(filename, File.localized(filename, language), strings_fn)
      scm.store_version!(filename)
      scm.store_version!(File.localized(filename, language))
    end
    
    def localize_incremental(language, scm)
      assert_localization_target(language)
      unless has_incremental_resources?(language, scm)
        localize(language, scm)
      else
        puts "Incrementally localizing #{filename} => #{File.localized(filename, language)}..."
        strings_fn = strings_filename(language)
        $logger.error "No strings file found: #{strings_fn}" unless File.exist?(strings_fn)
        
        scm.fetch_versions!(filename, File.localized(filename, language)) do |filenames|
          Babelyoda::Ibtool.localize_incrementally(filename, File.localized(filename, language), strings_fn, filenames[0], filenames[1])
        end
        scm.store_version!(filename)
        scm.store_version!(File.localized(filename, language))
      end
    end
    
    def strings_filename(language = nil)
      language ? File.localized(File.join(dirname, "#{basename}.strings"), language) : File.join(dirname, "#{basename}.strings")
    end
    
  private
    
    def has_incremental_resources?(language, scm)
      scm.version_exist?(filename) && scm.version_exist?(File.localized(filename, language))
    end
    
    def assert_localization_target(language)
      raise "Can't localize a XIB file that has not been put into an .lproj folder: #{filename}" unless resourced?
      raise "Can't localize #{@language} to #{language} for: #{filename}" if @language == language
    end
        
  end
end
