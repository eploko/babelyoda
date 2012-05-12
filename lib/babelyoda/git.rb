require_relative 'git_versions'
require_relative 'logger'
require_relative 'specification_loader'

module Babelyoda
	class Git
		include Babelyoda::SpecificationLoader

    def version_exist?(filename)
      versions.exist?(filename)
	  end
	  
	  def store_version!(filename)
	    versions[filename] = git_ls_sha1(filename)
      should_add = !File.exist?(versions.filename)
	    versions.save!
	    $logger.info "[SHA1] #{@versions[filename]} <= #{filename}"
    end
    
    def fetch_versions!(*filenames, &block)
      Dir.mktmpdir do |dir|
        results = []
        filenames.each do |fn|
          full_fn = File.join(dir, fn)
          dirname = File.dirname(full_fn)
          FileUtils.mkdir_p dirname
          git_show(@versions[fn], full_fn)
          results << full_fn
        end
        block.call(results)
      end
    end
    
    def transaction(msg)
      check_requirements!
      yield if block_given?
      if git_status.size > 0
        git_add!('.')
        git_add!('-u')
        git_commit!(msg)
      end
    end
		
  private

    def versions
	    @versions ||= GitVersions.new
    end
    
		def check_requirements!
		  unless clean?
		    $logger.error "The working copy is not clean. Please commit your work before running Babelyoda tasks." 
		    exit 1
		  end
		end

    def git_modified?(filename)
      git_status.has_key?(filename)
    end
    
    def git_status
      result = {}
      `git status --porcelain`.scan(/^(\sM|\sD|\?\?)\s+(.*)$/).each do |m|
        result[m[1]] = m[0]
      end
      result
    end
    
    def git_add!(filename)
	    ncmd = ['git', 'add', filename]
	    rc = Kernel.system(*ncmd)
	    $logger.error "#{ncmd}" unless rc
    end

    def git_commit!(msg)
	    ncmd = "git commit -m \"#{msg}\" 2>&1"
	    output = `#{ncmd}`
	    $logger.error ncmd unless $?
	    unless output.empty?
	      $logger.info output.gsub!(/[\n\r]/, ' ')
	    end
    end
    
    def git_show(sha1, filename = nil)
	    ncmd = ['git', 'show', sha1]
      IO.popen(ncmd) { |io|
        blob = io.read
        if filename
          File.open(filename, 'w') {|f| f.write(blob) }
        end
        blob
      }
	    $logger.error "#{ncmd}" unless $? == 0
    end
    
    def git_ls_sha1(filename)
      matches = `git ls-files -s '#{filename}'`.match(/^\d{6}\s+([^\s]+)\s+.*$/)
      $logger.error "Couldn't get SHA1 for: #{filename}" unless matches
      matches[1]
    end
  
    def clean?
      `git status 2>&1`.match(/^nothing to commit \(working directory clean\)$/)
	  end
	end
end
