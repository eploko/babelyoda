require_relative 'specification_loader'

module Babelyoda
	class Specification
		include Babelyoda::SpecificationLoader

    attr_accessor :name
    attr_accessor :development_language
    attr_accessor :localization_languages
    attr_accessor :engine

  end
end
