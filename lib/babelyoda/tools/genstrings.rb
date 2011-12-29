require 'tmpdir'

require 'babelyoda/engine'
require 'babelyoda/strings'

module Babelyoda
  module Tools
    class Genstrings
      def self.run(files = [])
        strings = {}
        engine = Babelyoda::Engine::Strings.new
        files.each do |fn|
          Dir.mktmpdir do |dir|
            raise "ERROR: genstrings failed." unless Kernel.system("genstrings -littleEndian -o '#{dir}' '#{fn}'")
            Dir.glob(File.join(dir, '*.strings')).each do |strings_file|
              name = File.basename(strings_file, '.strings')
              current_strings = engine.load_strings(strings_file)
              if strings[name]
                strings[name].merge!(current_strings)
              else
                strings[name] = current_strings
              end
            end
          end
        end
        if block_given?
          result = []
          strings.each_pair do |name, item|
            result << yield(name, item)
          end
          return result
        else
          return strings
        end
      end
    end
  end
end
