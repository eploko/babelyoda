require_relative 'strings'

module Babelyoda
  class Ibtool
    def self.extract_strings(xib_filename, language)
      Dir.mktmpdir do |dir|
        basename = File.basename(xib_filename, '.xib')
        strings_filename = File.join(dir, "#{basename}.strings")
        cmd = "ibtool --generate-strings-file '#{strings_filename}' '#{xib_filename}'"
        raise "ERROR: ibtool failed: #{cmd}" unless Kernel.system(cmd)
        return Babelyoda::Strings.new(strings_filename, language).read!
      end
    end
    
  private
  
  end
end
