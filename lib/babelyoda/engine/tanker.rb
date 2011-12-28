require 'babelyoda/specification_loader'

require_relative 'base'

module Babelyoda
	module Engine
		class Tanker < Base
			include Babelyoda::SpecificationLoader

	    attr_accessor :token
	    attr_accessor :project_id
	    attr_accessor :endpoint

		end
	end
end
