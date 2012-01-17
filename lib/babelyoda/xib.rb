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
    
    def strings_filename
      File.join(dirname, "#{basename}.strings")
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
      mv(lproj_filename(@language))
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
    
  private
  
    def lproj_filename(language)
      File.join(dirname, "#{language}.lproj", "#{basename}.xib")
    end
  end
end
