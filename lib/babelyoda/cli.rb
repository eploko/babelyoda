require 'thor'

module Babelyoda
	class CLI < Thor
	  desc "foo", "Prints foo"
	  def foo
	    puts "foo"
	  end
	end
end
