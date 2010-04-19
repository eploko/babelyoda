#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
  
module BabelYoda
  class Options
    
    #
    # Return a structure describing the options.
    #
    def self.parse
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = { 'rules' => 'rules.babelyoda' }

      optparser = OptionParser.new do |opts|
        opts.banner = "Usage: babelyoda [options]"

        opts.separator ""
        opts.separator "Common options:"
        
        # Optional argument; multi-line description.
        opts.on("-r", "--rules <RULES-FILE>",
                "Use the specified rules file.",
                "Default is 'babelyoda.rules'.") do |rules|
          options['rules'] = rules
        end        
        
        # No argument, shows at tail.  This will print an options summary.
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
      
      optparser.parse!
      options
    end
        
  end
end
