require 'awesome_print'

module Babelyoda
	module SpecificationLoader
		def self.included(klass)
	    klass.extend ClassMethods
	  end

    def initialize(*args, &block)
    	super
    	block.call(self)
    end

	  def method_missing(method_name, *args, &block)
	    msg = "You tried to call the method #{method_name}. There is no such method."
	    raise msg
  	end

    def dump
    	ap self, :indent => -2
    end

    module ClassMethods

		  def load(filename)
		    spec = eval(File.read(filename))
		    raise "Wrong specification class: #{spec.class.to_s}" unless spec.instance_of?(self)
		    return spec
		  end

    end

	end
end
