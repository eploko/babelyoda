require_relative 'specification_loader'

module Babelyoda
  class LengthCheckerParams
    include Babelyoda::SpecificationLoader

    attr_accessor :ratio
    attr_accessor :delta
  end
end