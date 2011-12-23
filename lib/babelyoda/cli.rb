require 'thor'

require_relative 'project'
require_relative 'specification'
require_relative 'engine'

module Babelyoda
	class CLI < Thor
		include Thor::Actions

 		source_root(File.join(File.dirname(__FILE__), '..', '..'))

		desc "init NAME", "Initialize Babelyoda project spec file"
		# method_option :name, :type => :string, :required => true
		def init(name)
			specfile_name = "#{name}.babelyoda"
      template('templates/babelspec.erb', specfile_name, { :name => name})
      puts "'#{specfile_name}' has been generated. Please fix all occurances of 'FIX:' in it."
		end

	  desc "push NAME", "Pushes resources to the translators"
	  def push(name)
	  	spec = load_specification(name)
	    project = Babelyoda::Project.new(spec)
	    project.push
	  end

	  desc "pull NAME", "Merges new translations into the resources"
	  def pull(name)
	  	spec = load_specification(name)
	    project = Babelyoda::Project.new(spec)
	    project.push
	  end

	private

		def load_specification(name)
	    spec = Babelyoda::Specification.load("#{name}.babelyoda")
	    spec.dump
	    return spec
		end
	end
end
