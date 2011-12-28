BABELYODA_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require_relative 'babelyoda/engine'
require_relative 'babelyoda/keyset'
require_relative 'babelyoda/specification'
require_relative 'babelyoda/tools'
require_relative 'babelyoda/rake'

namespace :babelyoda do
  
  file 'Babelfile' do
    Babelyoda::Specification.generate_default_babelfile
  end
  
  desc "Create a basic bootstrap Babelfile"
  task :init => 'Babelfile' do
  end
  
  Babelyoda::Rake.spec do |spec|

    desc "Extract strings with genstrings"
    task :genstrings do
      strings = Babelyoda::Tools::Genstrings.run(spec.source_files)
      p strings['YMSearchResultLayer']
    end
        
    desc "Pushes resources to the translators"
    task :push => :genstrings do
    end
  
  end
end
