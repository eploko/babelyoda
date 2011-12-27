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
          return Record.new(bits[0], bits[1], bits[3])
        end
        match_bs(bs, :singleline_comment, :string, :equal_sign, :string, :semicolon) do |bits|
          return Record.new(bits[0], bits[1], bits[3])
        end
        match_bs(bs, :string, :equal_sign, :string, :semicolon) do |bits|
          return Record.new(nil, bits[0], bits[2])
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
      
      def emit_comment
        if @token == :singleline_comment
          @value.sub!(/^\/\/\s*/, '')
        elsif @token == :multiline_comment
          @value.sub!(/^\/\*\s*/, '').sub!(/\s*\*\/$/, '')
        end
        @record[:comment] = @value
      end
      
      def emit_key
        @value.sub!(/^\"/, '')
        @value.sub!(/\"$/, '')
        @record[:key] = @value        
      end
      
      def emit_value
        @value.sub!(/^\"/, '').sub!(/\"$/, '')
        @record[:value] = @value        
      end
      
      def emit_record
        @block.call(@record)
        @record = nil
      end
    end
    
    def initialize
      @records = {}
    end
    
    def self.read(fn)
      result = new
      result.read(fn)
      return result
    end
    
    def read(fn)
      lexer = Lexer.new
      parser = Parser.new(lexer)
      parser.parse(File.read(fn)) do |record|
        # puts "RECORD: #{record}"
        if @records.has_key?(record[:key])
          puts "WARNING: Duplicate key '#{record[:key]}', dupe spotted in '#{fn}'"
        else
          @records[record[:key]] = record
        end
      end        
    end
    
    def size
      @records.size
    end
  end
end
