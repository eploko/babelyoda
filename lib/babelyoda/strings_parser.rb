require_relative 'localization_key'
require_relative 'localization_value'

module Babelyoda
  class StringsParser
    Bit = Struct.new(:token, :value)

    def initialize(lexer, language)
      @lexer, @language = lexer, language
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
        localization_key = LocalizationKey.new(cleanup_string(bits[1]), cleanup_comment(bits[0]))
        localization_value = LocalizationValue.new(@language, cleanup_string(bits[3]))
        localization_key << localization_value
        return localization_key
      end
      match_bs(bs, :singleline_comment, :string, :equal_sign, :string, :semicolon) do |bits|
        localization_key = LocalizationKey.new(cleanup_string(bits[1]), cleanup_comment(bits[0]))
        localization_value = LocalizationValue.new(@language, cleanup_string(bits[3]))
        localization_key << localization_value
        return localization_key
      end
      match_bs(bs, :string, :equal_sign, :string, :semicolon) do |bits|
        localization_key = LocalizationKey.new(cleanup_string(bits[0]), nil)
        localization_value = LocalizationValue.new(@language, cleanup_string(bits[2]))
        localization_key << localization_value
        return localization_key
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
end
