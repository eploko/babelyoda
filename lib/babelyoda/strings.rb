module Babelyoda
  class Strings
    Record = Struct.new(:comment, :key, :value)

    class Lexer
      TOKENS = [ :multiline_comment, :singleline_comment, :string, :reserved0, :equal_sign, :semicolon ].freeze
      
      def lex(str)
        str.scan(/(\/\*.*\*\/)|(\s*\/\/.*\n)|((["])(?:\\?+.)*?\4)|(\s*=\s*)|(;)/).each do |m|
          idx = m.index { |x| x }
          # puts "#{TOKENS[idx]}: #{m[idx].strip}"
          yield TOKENS[idx], m[idx].strip
        end
      end
    end
    
    class Parser
      Bit = Struct.new(:token, :value)
      
      def initialize(lexer)
        @lexer = lexer
      end
      
      def parse(str, &block)
        @block = block
        bitstream = []
        @lexer.lex(str) do | token, value |
          bitstream << Bit.new(token, value)
        end
        while bitstream.size > 0
          record = produce(bitstream)
          @block.call(record) if record
        end
      end
      
      def produce(bs)
        match_bs(bs, :multiline_comment, :string, :equal_sign, :string, :semicolon) do |bits|
          return Record.new(cleanup_comment(bits[0]), cleanup_string(bits[1]), cleanup_string(bits[3]))
        end
        match_bs(bs, :singleline_comment, :string, :equal_sign, :string, :semicolon) do |bits|
          return Record.new(cleanup_comment(bits[0]), cleanup_string(bits[1]), cleanup_string(bits[3]))
        end
        match_bs(bs, :string, :equal_sign, :string, :semicolon) do |bits|
          return Record.new(nil, cleanup_string(bits[0]), cleanup_string(bits[2]))
        end
        match_bs(bs, :singleline_comment) do |bits|
          return nil
        end
        match_bs(bs, :multiline_comment) do |bits|
          return nil
        end
        raise "Syntax error: #{bs.shift(5).inspect}"
      end
      
      def match_bs(bs, *tokens)
        return unless bs.size >= tokens.size
        tokens.each_with_index do |token, idx|
          return unless bs[idx][:token] == token 
        end
        yield bs.shift(tokens.size).map { |bit| bit[:value] }
      end
      
      def prepare_record
        @record = Record.new
      end
      
      def cleanup_comment(str)
        if str.match(/^\/\/\s*/)
          str.sub(/^\/\/\s*/, '')
        else
          str.sub(/^\/\*\s*/, '').sub(/\s*\*\/$/, '')
        end
      end
      
      def cleanup_string(str)
        str.sub(/^\"/, '').sub(/\"$/, '')
      end
    end
    
    attr_reader :records
    
    def initialize
      @records = {}
    end
    
    def self.read(fn)
      result = new
      result.read(fn)
      return result
    end
    
    def read(fn)
      File.open(fn, "rb:UTF-16LE:UTF-8") do |file|
        dupes = {}
        lexer = Lexer.new
        parser = Parser.new(lexer)
        parser.parse(file.read) do |record|
          if @records.has_key?(record[:key]) && @records[record[:key]][:comment] != record[:comment]
            unless dupes[record[:key]]
              dupes[record[:key]] = [ @records[record[:key]][:comment] ]
            end
            dupes[record[:key]] << record[:comment]
          else
            @records[record[:key]] = record
          end
        end        
        dupes.each_pair do |key, comments|
          puts "Warning: Key \"#{key}\" used with multiple comments #{comments.map{|c| "\"#{c}\""}.join(' & ')}"
        end
      end
    end
    
    def write(fn)
      FileUtils.mkdir_p(File.dirname(fn), :verbose => true)
      File.open(fn, "wb:UTF-16LE:UTF-8") do |f|
        @records.each_pair do |key, record|
          f << "/* #{record[:comment]} */\n" if record[:comment]
          f << "\"#{record[:key]}\" = \"#{record[:value]}\";\n"
          f << "\n"
        end
      end
      puts "WRITTEN: #{fn}"
    end
    
    def size ; @records.size ; end
    
    def keys ; @records.keys ; end
    
    def merge!(strings)
      strings.records.each_pair do |key, value|
        puts "WARNING: Key '#{key}' has been overwritten while merging." if @records.has_key?(key)
        @records[key] = value
      end
    end
    
    def [](key) ; @records[key] ; end
  end
end
