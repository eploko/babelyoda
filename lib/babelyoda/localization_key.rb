module Babelyoda
  class LocalizationKey
    attr_reader :id
    attr_reader :context
    attr_reader :values
    
    def initialize(id, context)
      @id = id
      @context = context
      @values = {}
    end
    
    def <<(localization_value)
      @values[localization_value.language.to_sym] = localization_value.dup
      self
    end
    
    def merge!(localization_key, options = {})
      updated = false
      
      context_changed = false
      if @context != localization_key.context
        @context = localization_key.context
        updated = context_changed = true
      end
      
      localization_key.values.each_value do |value|
        if @values.has_key?(value.language.to_sym)
          updated = true if @values[value.language.to_sym].merge!(value, options)
        else
          @values[value.language.to_sym] = value.dup
          updated = true
        end
      end
      
      # Mark all values as requiring translation if the context has changed.
      if context_changed
        @values.each_value do |value|
          value.status = :requires_translation
        end
      end
      
      return updated
    end
    
    def drop_empty!
      @values.delete_if do |id, value|
        value.text.empty?
      end
    end
    
    def empty?
      @values.empty?
    end
  end
end
