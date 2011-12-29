require 'rchardet19'

require 'babelyoda/strings'
require_relative 'base'
require_relative 'strings_lexer'
require_relative 'strings_parser'

module Babelyoda
	module Engine
		class Strings < Base

      def load_keyset(name)
        keyset = Babelyoda::Keyset.new(name)
        Dir.glob(strings_filename(name, '*')).each do |filename|
          keyset.strings[lang_from_filename(filename)] = load_strings(filename)
        end
        return keyset
      end
      
      def load_strings(filename)
        return nil unless File.exist?(filename)
        
        strings = Babelyoda::Strings.new
        File.open(filename, read_mode_for_filename(filename)) do |f|
          lexer = StringsLexer.new
          parser = StringsParser.new(lexer)
          parser.parse(f.read) do |record|
            unless strings.records.has_key?(record[:key])
              strings.records[record[:key]] = record
            end
          end        
        end

        return yield(strings) if block_given?
        return strings
      end      

      def save_keyset(keyset, langs = keyset.langs)
        langs.each do |lang|
          filename = strings_filename(keyset.name, lang)
          save_strings(keyset.strings[lang], filename)
        end
      end
      
      def save_strings(strings, filename)
        FileUtils.mkdir_p(File.dirname(filename))
        File.open(filename, "wb") do |f|
          strings.records.each_pair do |key, record|
            f << "/* #{record[:comment]} */\n" if record[:comment]
            f << "\"#{record[:key]}\" = \"#{record[:value]}\";\n"
            f << "\n"
          end
        end
        puts "WRITTEN: #{filename}"
      end
      
    private
    
      def strings_filename(name, lang)
        File.join(File.dirname(name), "#{lang}.lproj", File.basename(name) + ".strings")
      end
      
      def lang_from_filename(filename)
        File.split(File.split(filename)[0])[1].match(/^(.*)\.lproj$/)[1].to_sym
      end
            
      def read_mode_for_filename(fn)
        cd = CharDet.detect(File.read(fn))
        encoding_str = Encoding.aliases[cd.encoding] || cd.encoding
        encoding_str = 'UTF-8' if encoding_str == 'utf-8'
        if (encoding_str != "UTF-8")
          "rb:#{encoding_str}:UTF-8"
        else
          "r"
        end
      end
            
		end
	end
end
