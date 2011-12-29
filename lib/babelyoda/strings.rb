module Babelyoda
  class Strings
    Record = Struct.new(:comment, :key, :value)
    
    attr_reader :records
    
    def initialize
      @records = {}
    end
        
    def size ; @records.size ; end
    
    def keys ; @records.keys ; end
    
    def merge!(strings, opts = {})
      opts[:keep_values] = true unless opts.has_key?(:keep_values)
      strings.records.each_pair do |key, value|
        if !@records.has_key?(key) || (@records.has_key?(key) && !opts[:keep_values])
          @records[key] = value
        end
      end
      return self
    end
    
    def [](key) ; @records[key] ; end
    
    def purge_keys_not_in!(strings)
      records_to_purge = @records.select { |key, value| !strings.records.has_key?(key) }
      records_to_purge.keys.each { |key| @records.delete(key) }
      return self
    end    
  end
end
