module Babelyoda
  class LengthChecker
    def initialize(dev_language, params)
      @dev_language = dev_language
      @params = params
    end

    def long_translations(keyset)
      long_translations = {}

      keyset.keys.each_value do |key|
        dev_value = key.values[@dev_language]
        dev_text = longest_translation(dev_value)
        dev_len = dev_text.length.to_f

        key.values.each_value do |value|
          text = longest_translation(value)
          len = text.nil? ? 0 : text.length
          ratio = len/dev_len
          big_ratio = ratio >= @params.ratio
          big_delta = (len - dev_len) >= @params.delta

          if big_ratio && big_delta
            lang = value.language.to_sym
            translation = Babelyoda::LongTranslation.new(dev_text, text, key.context)
            if long_translations.has_key?(lang)
              long_translations[lang].push(translation)
            else
              long_translations[lang] = [translation]
            end
          end
        end
      end
      long_translations
    end

  private

    def longest_translation(localizaition_value)
      if localizaition_value.plural?
        translation = localizaition_value.text.values.max_by {|str| str.nil? ? 0 : str.length}
      else
        translation = localizaition_value.text
      end
      translation
    end
  end

  class LongTranslation
    attr_accessor :dev_text
    attr_accessor :text
    attr_accessor :context
    
    def initialize(dev_text, text, context)
      @dev_text = dev_text
      @text = text
      @context = context
    end
  end
end