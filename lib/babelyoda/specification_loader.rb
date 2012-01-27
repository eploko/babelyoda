require 'awesome_print'

module Babelyoda
	module SpecificationLoader
		def self.included(klass)
	    klass.extend ClassMethods
	  end

    def initialize(*args)
    	super
    	yield(self) if block_given?
    end

	  def method_missing(method_name, *args, &block)
	    msg = "You tried to call the method #{method_name}. There is no such method."
	    raise msg
  	end

    def dump
      unless ::Rake.application.options.trace
      	ap self, :indent => -2
      else
      	p self
      end
    end
    
    module ClassMethods

		  def load_from_file(filename)
		    return nil unless File.exist?(filename)
		    spec = eval(File.read(filename))
		    raise "Wrong specification class: #{spec.class.to_s}" unless spec.instance_of?(self)
		    return spec
		  end
		  
    end

	end
end
