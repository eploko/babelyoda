require 'babelyoda/strings'

require_relative 'base'

module Babelyoda
	module Engine
		class Strings < Base

      def load_keyset(name)
        keyset = Babelyoda::Keyset.new(name)
        puts "Loading: #{name}"

        Dir.glob(strings_filename(name, '*')).each do |filename|
          keyset.strings[lang_from_filename(filename)] = Babelyoda::Strings.read(filename)
        end
        
        return keyset
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
