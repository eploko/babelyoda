module BabelYoda
  class StringsHelper
    def self.safe_init_strings_file(path)
      unless File.exists? path
        empty_strings_file = File.join File.dirname(__FILE__), '..', '..', 'data', 'empty.strings'
        FileUtils.mkdir_p File.split(path)[0], :verbose => true
        FileUtils.cp empty_strings_file, path, :verbose => true
      end
    end
  end
end
