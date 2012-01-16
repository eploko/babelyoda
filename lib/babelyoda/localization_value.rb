module Babelyoda
  class LocalizationValue
    attr_accessor :language
    attr_accessor :status
    attr_accessor :text
    
    def initialize(language, text, status = :requires_translation)
      @language, @text, @status = language.to_sym, text, status.to_sym
    end
    
    def merge!(other_value, options = {})
      updated = false
      options = { preserve: false }.merge!(options)
      unless @language.to_sym == other_value.language.to_sym
        raise RuntimeError.new("Can't merge values in different languages: #{@language.to_sym} and #{other_value.language.to_sym}") 
      end
      if (!options[:preserve] || @status.to_sym == :requires_translation)
        unless @text == other_value.text
          @text = other_value.text 
          updated = true
        end
      end
      return updated
    end
  end
end
