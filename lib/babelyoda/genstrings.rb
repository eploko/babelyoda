require 'fileutils'
require 'tmpdir'

require_relative 'logger'
require_relative 'keyset'
require_relative 'strings'

module Babelyoda
  class Genstrings
    def self.run(files = [], language, &block)
      keysets = {}
      files.each do |fn|
        Dir.mktmpdir do |dir|
          ncmd = "genstrings -littleEndian -o '#{dir}' '#{fn}' 2>&1"
          output = `#{ncmd}`
          raise "genstrings failed: #{ncmd}#{output.empty? ? "" : " #{output}"}" unless $?
          unless output.empty?
            $logger.warn output.gsub!(/[\n\r]/, ' ')
          end
          Dir.glob(File.join(dir, '*.strings')).each do |strings_file|
            strings = Babelyoda::Strings.new(strings_file, language).read!
            strings.name = File.join('Resources', File.basename(strings.name))
            keysets[strings.name] ||= Keyset.new(strings.name)
            keysets[strings.name].merge!(strings)
          end
        end
      end
      keysets.each_value do |item|
        yield(item)
      end
    end
  end
end
