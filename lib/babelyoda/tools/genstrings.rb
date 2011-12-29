require 'tmpdir'

require 'babelyoda/strings'

module Babelyoda
  module Tools
    class Genstrings
      def self.run(files = [])
        strings = {}
        files.each do |fn|
          Dir.mktmpdir do |dir|
            raise "ERROR: genstrings failed." unless Kernel.system("genstrings -littleEndian -o '#{dir}' '#{fn}'")
            Dir.glob(File.join(dir, '*.strings')).each do |strings_file|
              basename = File.basename(strings_file, '.strings')
              strings[basename] ||= Babelyoda::Strings.new
              strings[basename].read(strings_file)
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
