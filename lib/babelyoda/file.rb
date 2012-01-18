class File
  def self.lproj_part(filename)
    filename.split('/').each do |part|
      return part if part =~ /^.*\.lproj$/
    end
    nil
  end
  
  def self.omit_lproj(filename)
    File.join(filename.split('/').delete_if { |p| p.match(/^.*\.lproj$/) })
  end
  
  def self.localized(filename, language)
    if lproj_part(filename)
      File.join(filename.split('/').map { |p| p.match(/^.*\.lproj$/) ? "#{language}.lproj" : p })
    else
      File.join(File.dirname(filename), "#{language}.lproj", File.basename(filename))
    end
  end
end
