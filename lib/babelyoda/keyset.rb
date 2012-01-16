module Babelyoda
  class Keyset
    attr_accessor :name
    attr_accessor :keys
    
    def initialize(name)
      @name = name
      @keys = {}
    end
    
    def merge!(keyset)
      # puts "MERGE: #{name} << #{keyset.name}"
      keyset.keys.each_pair do |id, key|
        if @keys.has_key?(id)
          @keys[id].merge!(key)
        else
          @keys[id] = key.dup
        end
      end
    end
  end
end
