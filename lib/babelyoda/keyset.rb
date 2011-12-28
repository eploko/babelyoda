module Babelyoda
  class Keyset
    attr_accessor :name
    attr_accessor :strings
    
    def initialize(name)
      @name = name
      @strings = {}
    end
    
    def merge!(keyset)
      keyset.strings.each_pair do |lang, strings|
        @strings[lang] = Babelyoda::Strings.new unless @strings.has_key?(lang)
        @strings[lang].merge!(strings)
      end
    end
    
    def to_s
      "<Babelyoda::Keyset[#{langs.join(', ')}]: #{size} keys>"
    end
    
    def langs ; @strings.keys ; end
    
    def keys
      total_keys = []
      @strings.each_value { |strings| total_keys << strings.keys }
      total_keys.flatten!.uniq!
    end
    
    def size ; keys.size ; end
  end
end
