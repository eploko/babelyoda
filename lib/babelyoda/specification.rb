require 'awesome_print'

module Babelyoda
	class Specification

    attr_accessor :name
    attr_accessor :development_language
    attr_accessor :localization_languages
    attr_accessor :engine

    def initialize(*args, &block)
    	super
    	block.call(self)
    end

	  def self.load(filename)
	    spec = eval(File.read(filename))
	    raise "Wrong specification class: #{spec.class.to_s}" unless spec.instance_of?(self)
	    return spec
	  end

	  def method_missing(method_name, *args, &block)
	    msg = "You tried to call the method #{method_name}. There is no such method."
	    raise msg
  	end

    def dump
    	ap to_hash, :indent => -2
    end

    def to_hash
    	keys = [ :name, :development_language, :localization_languages, :engine ]
    	result = {}
    	keys.each { |k| result[k] = self.send(k) }
    	return result
	  end

  end
end
