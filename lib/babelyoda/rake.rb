require_relative 'specification'

module Babelyoda
  module Rake
    def self.spec(&block)
      spec = Babelyoda::Specification.load
      block.call(spec) if spec
    end
  end
end
