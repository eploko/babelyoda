class String
  def escape_double_quotes
    self.gsub(/([^\\]|^)"/, "\\1\\\"")
  end
end
