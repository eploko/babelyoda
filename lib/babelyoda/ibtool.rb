require_relative 'logger'
require_relative 'strings'

module Babelyoda
  class Ibtool
    def self.extract_strings(xib_filename, language)
      Dir.mktmpdir do |dir|
        basename = File.basename(xib_filename, '.xib')
        strings_filename = File.join(dir, "#{basename}.strings")
        cmd = "ibtool --generate-strings-file '#{strings_filename}' '#{xib_filename}'"
        $logger.error "IBTOOL ERROR: #{cmd}" unless Kernel.system(cmd)
        return Babelyoda::Strings.new(strings_filename, language).read!
      end
    end
    
    def self.localize(source_xib_fn, target_xib_fn, strings_fn)
      # ibtool
      #   --strings-file path_to_strings/fr/MainWindow.strings                      # The latest localized strings for the French XIB
      #   --write path_to_project/fr.lproj/MainWindow.xib                           # The new French XIB that will be created
      #   path_to_project/English.lproj/MainWindow.new.xib                          # The new English XIB

      ncmd = ['ibtool', '--strings-file', strings_fn, '--write', target_xib_fn, source_xib_fn]
      rc = Kernel.system(*ncmd)
      $logger.error "IBTOOL ERROR: #{ncmd}" unless rc
    end
    
    def self.localize_incrementally(source_xib_fn, target_xib_fn, strings_fn, old_source_xib_fn, old_target_xib_fn)
      # ibtool
      #   --previous-file path_to_project/English.lproj/MainWindow.old.xib          # The old English XIB
      #   --incremental-file path_to_project/fr.lproj/MainWindow.old.xib            # The old French XIB
      #   --strings-file path_to_strings/fr/MainWindow.strings                      # The latest localized strings for the French XIB
      #   --localize-incremental
      #   --write path_to_project/fr.lproj/MainWindow.xib                           # The new French XIB that will be created
      #   path_to_project/English.lproj/MainWindow.new.xib                          # The new English XIB

      ncmd = ['ibtool', '--previous-file', old_source_xib_fn, '--incremental-file', old_target_xib_fn, 
        '--strings-file', strings_fn, '--localize-incremental', '--write', target_xib_fn, source_xib_fn]
      rc = Kernel.system(*ncmd)
      $logger.error "IBTOOL ERROR: #{ncmd}" unless rc
    end
    
    def self.import_strings(filename, strings_filename)
      ncmd = ['ibtool', '--import-strings-file', strings_filename, '--write', filename, filename]
      rc = Kernel.system(*ncmd)
      $logger.error "IBTOOL ERROR: #{ncmd}" unless rc
    end
    
  private
  
  end
end
