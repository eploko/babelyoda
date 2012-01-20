require 'rchardet19'

require_relative 'file'
require_relative 'keyset'
require_relative 'strings_lexer'
require_relative 'strings_parser'

module Babelyoda
	class Strings < Keyset
	  attr_reader :filename
	  attr_reader :language
	  
	  def initialize(filename, language)
	    super(Babelyoda::Keyset.keyset_name(filename))
	    @filename, @language = filename, language
	  end

	  def read!
      raise ArgumentError.new("File not found: #{filename}") unless File.exist?(@filename)
      read
    end
    
    def read
      if File.exist?(@filename)
        File.open(@filename, read_mode) do |f|
          lexer = StringsLexer.new
          parser = StringsParser.new(lexer, @language)
          parser.parse(f.read) do |localization_key|
            merge_key!(localization_key)
          end        
        end
      end
      self
    end      

    def save!
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "wb") do |f|
        keys.each_pair do |id, key|
          next unless key.values[language]
          f << "/* #{key.context} */\n" if key.context
          f << "\"#{id}\" = \"#{key.values[language].text}\";\n"
          f << "\n"
        end
      end
    end
    
    def self.save_keyset(keyset, filename, language)
      strings = self.new(filename, language)
      strings.merge!(keyset)
      strings.save!
    end
    
  private
            
    def read_mode
      cd = CharDet.detect(File.read(@filename))
      encoding_str = Encoding.aliases[cd.encoding] || cd.encoding
      encoding_str = 'UTF-8' if encoding_str == 'utf-8'
      encoding_str = 'UTF-8' if encoding_str == 'ascii'
      if (encoding_str != "UTF-8")
        "rb:#{encoding_str}:UTF-8"
      else
        "r"
      end
    end
          
	end
end
