require 'babelyoda/strings'

require_relative 'base'

module Babelyoda
	module Engine
		class Strings < Base

      def load_keyset(name)
        keyset = Babelyoda::Keyset.new(name)
        Dir.glob(strings_filename(name, '*')).each do |filename|
          keyset.strings[lang_from_filename(filename)] = Babelyoda::Strings.read(filename)
        end
        return keyset
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
            
		end
	end
end
