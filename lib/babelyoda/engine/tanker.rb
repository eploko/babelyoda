require 'babelyoda/specification_loader'

module Babelyoda
	module Engine
		class Tanker
			include Babelyoda::SpecificationLoader

	    attr_accessor :token
	    attr_accessor :project_id
	    attr_accessor :endpoint

		end
	end
end
