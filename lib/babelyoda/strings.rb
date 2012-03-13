require 'rchardet19'

require_relative 'file'
require_relative 'keyset'
require_relative 'string'
require_relative 'strings_lexer'
require_relative 'strings_parser'

module Babelyoda
  class Keyset
    def to_strings(io, language)
      keys.each_value do |key|
        key.to_strings(io, language)
      end
    end
  end
  
  class LocalizationKey
    def to_strings(io, language)
      return if self.values[language].nil?
      io << "/* #{self.context} */\n" if self.context
      if plural?
        values[language].text.keys.each do |plural_key|
          if values[language].text[plural_key] != nil && values[language].text[plural_key].length > 0
            io << "\"#{pluralize_key(id, plural_key).escape_double_quotes}\" = \"#{values[language].text[plural_key].escape_double_quotes}\";\n"
          end
        end
      else
        io << "\"#{id.escape_double_quotes}\" = \"#{values[language].text.escape_double_quotes}\";\n"
      end
      io << "\n"
    end
  end
  
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
        to_strings(f, language)
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
