require 'tmpdir'

require_relative 'keyset'
require_relative 'strings'

module Babelyoda
  class Genstrings
    def self.run(files = [], language, &block)
      keysets = {}
      files.each do |fn|
        Dir.mktmpdir do |dir|
          raise "ERROR: genstrings failed." unless Kernel.system("genstrings -littleEndian -o '#{dir}' '#{fn}'")
          Dir.glob(File.join(dir, '*.strings')).each do |strings_file|
            strings = Babelyoda::Strings.new(strings_file, language).read!
            keyset_name = File.basename(strings_file, '.strings')
            keysets[keyset_name] ||= Keyset.new(keyset_name)
            keysets[keyset_name].merge!(strings)
          end
        end
      end
      keysets.each_value do |item|
        yield(item)
      end
    end
  end
end
