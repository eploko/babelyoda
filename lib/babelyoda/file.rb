class File
  def self.lproj_part(filename)
    filename.split('/').each do |part|
      return part if part =~ /\.lproj$/
    end
    nil
  end
end
