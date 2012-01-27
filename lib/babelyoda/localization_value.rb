require_relative 'regexp'

module Babelyoda
  class LocalizationValue
    attr_accessor :language
    attr_accessor :status
    attr_accessor :text
    
    def initialize(language, text, status = :requires_translation)
      @language, @text, @status = language.to_sym, text, status.to_sym
      pluralize! if plural_id?(@text)
    end
    
    def pluralize!(plural_key = :one)
      return if plural?
      new_text = { :one => nil, :some => nil, :many => nil, :none => nil }

      if plural_id?(text)
        m = plural_match(text)
        new_text[m[2].to_sym] = depluralize_value(@text)
      else
        new_text[plural_key] = text
      end
      
      @text = new_text
    end
    
    def plural? ; text.kind_of? Hash ; end
    
    def merge!(other_value, options = {})
      updated = false
      options = { preserve: false }.merge!(options)

      unless @language.to_sym == other_value.language.to_sym
        raise "Can't merge values in different languages: #{@language.to_sym} and #{other_value.language.to_sym}"
      end
      
      raise "Can't merge a plural and a non-plural value!" unless plural? == other_value.plural?

      if plural?
        [:one, :some, :many, :none].each do |plural_type|
          key_updated = merge_plural_type!(plural_type, other_value.text[plural_type], options)
          updated ||= key_updated
        end
      else
        if (!options[:preserve] || @status.to_sym == :requires_translation)
          if @text != other_value.text && !other_value.nil?
            @text = other_value.text 
            updated = true
          end
        end
      end
      return updated
    end
    
  private
    include Babelyoda::Regexp
    
    def merge_plural_type!(type, other_value, options)
      if (!options[:preserve] || @status.to_sym == :requires_translation)
        if @text[type] != other_value && !other_value.nil?
          @text[type] = other_value 
          return true
        end
      end
      return false
    end
  end
end
