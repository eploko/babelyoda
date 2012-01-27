require_relative 'regexp'

module Babelyoda
  class LocalizationKey
    attr_reader :id
    attr_reader :context
    attr_reader :values
    
    def initialize(id, context)
      @id = id
      @context = context
      @values = {}
      @plural = plural_id?(id)
      @plural_key = plural? ? extract_plural_key(id) : nil
      @id = depluralize_key(@id) if plural?
    end
    
    def to_s
      "\"#{@id}\" [#{@values.keys.map{|k| ":#{k.to_s}"}.join(', ')}] // #{@context}"
    end
    
    def plural? ; @plural ; end
    
    def <<(localization_value)
      raise "Can't merge a plural value into a non-plural key" if !plural? && localization_value.plural?
      lang = localization_value.language.to_sym
      value = localization_value.dup
      if plural?
        value.pluralize!(@plural_key)
        if @values[lang]
          @values[lang].merge!(value, { :preserve => true })
        else
          @values[lang] = value
        end
      else
        @values[lang] = value
      end
      self
    end
    
    def merge!(localization_key, options = {})
      updated = false
      
      context_changed = false
      new_context = localization_key.context
      if @context != new_context && new_context != nil && new_context.length > 0
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
    
    def ensure_languages!(languages = [])
      languages.each do |language|
        unless self.values[language]
          self << Babelyoda::LocalizationValue.new(language, '')
        end 
      end      
    end    
    
  private
    include Babelyoda::Regexp
  end
end
