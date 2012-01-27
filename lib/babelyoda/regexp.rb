module Babelyoda
  module Regexp
    PLURAL_ID = /([^%]|^)%\[(one|some|many|none|plural)\]([^\s])/
    PLURALIZED_ID = /([^%]|^)%\[(plural)\]([^\s])/
    
    def plural_id?(id)
      plural_match(id) != nil
    end
    
    def plural_match(id)
      id.match(PLURAL_ID)
    end
    
    def depluralize_value(id)
      id.gsub(PLURAL_ID, '\1%\3')
    end

    def depluralize_key(id)
      id.gsub(PLURAL_ID, '\1%[plural]\3')
    end
    
    def pluralize_key(id, plural_key)
      id.gsub(PLURALIZED_ID, "\\1%[#{plural_key}]\\3")
    end
    
    def extract_plural_key(id)
      id.match(PLURAL_ID)[2].to_sym
    end
  end
end
