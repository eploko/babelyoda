require_relative 'git_versions'
require_relative 'logger'
require_relative 'specification_loader'

module Babelyoda
	class Git
		include Babelyoda::SpecificationLoader

		attr_accessor :target_branch
		attr_accessor :localization_branch_prefix
		
		def check_requirements!
		  $logger.error "GIT: The working copy is not clean. Please commit your work before running Babelyoda tasks." unless clean?
		  $logger.error "GIT: The target branch is not found: #{target_branch}" unless target_branch_exist?
		end
		
		def prepare!
		  checkout!(target_branch)
	    branch!
	    @versions = GitVersions.new
		end

    def version_exist?(filename)
      versions.exist?(filename)
	  end
	  
	  def store_version!(filename)
	    if git_modified?(filename)
  	    git_add!(filename)
  	    git_commit!("Store a version of '#{filename}' for later use in incremental localization.")
  	  end
	    @versions[filename] = git_ls_sha1(filename)
      should_add = !File.exist?(versions.filename)
	    versions.save!
	    if should_add || git_modified?(versions.filename)
  	    git_add!(versions.filename)
  	    git_commit!("Update the versions file.")
  	  end
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
		
  private
  
    attr_reader :versions
    
    def git_modified?(filename)
      git_status.has_key?(filename)
    end
    
    def git_status
      result = {}
      `git status --porcelain`.scan(/^(\sM|\?\?)\s+(.*)$/).each do |m|
        result[m[1]] = m[0]
      end
      result
    end
    
    def git_add!(filename)
	    ncmd = ['git', 'add', filename]
	    rc = Kernel.system(*ncmd)
	    $logger.error "GIT ERROR: #{ncmd}" unless rc
    end

    def git_commit!(msg)
	    ncmd = ['git', 'commit', '-m', msg]
	    rc = Kernel.system(*ncmd)
	    $logger.error "GIT ERROR: #{ncmd}" unless rc
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
	    $logger.error "GIT ERROR: #{ncmd}" unless $? == 0
    end
    
    def git_ls_sha1(filename)
      matches = `git ls-files -s '#{filename}'`.match(/^\d{6}\s+([^\s]+)\s+.*$/)
      $logger.error "GIT ERROR: Couldn't get SHA1 for: #{filename}" unless matches
      matches[1]
    end
  
    def clean?
      `git status 2>&1`.match(/^nothing to commit \(working directory clean\)$/)
	  end
	  
	  def target_branch_exist?
	    `git branch 2>&1`.match(/^(\*\s|\s\s)#{target_branch}$/)
	  end
	  
	  def current_branch
	    `git branch 2>&1`.match(/^\*\s(.*)$/)[1]
    end
    
    def ensure_branch!(branch)
      $logger.error "Invalid branch. Expected: #{target_branch}" unless current_branch == branch
    end
    
    def checkout!(branch, create = false)
		  puts "GIT: Checking out #{create ? 'NEW ' : ''}branch '#{branch}'..."
		  output = `git checkout #{create ? '-b ' : ''}'#{branch}' 2>&1`
		  okay = false
		  unless create
		    okay = output.match(/^(Switched to branch '#{branch}'|Already on '#{branch}')$/)
		  else
		    okay = output.match(/^Switched to a new branch '#{branch}'$/)
		  end
		  $logger.error "Couldn't checkout branch '#{branch}': #{output}" unless okay
	    ensure_branch!(branch)
    end
    
    def branch!
      branch_name = "#{localization_branch_prefix}#{Time.now.to_i}"
      checkout!(branch_name, true)
    end
	end
end
