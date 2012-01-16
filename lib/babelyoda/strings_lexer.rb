module Babelyoda
  class StringsLexer
    TOKENS = [ :multiline_comment, :singleline_comment, :string, :reserved0, :equal_sign, :semicolon ].freeze

    def lex(str)
      str.scan(/(\/\*.*\*\/)|(\s*\/\/.*\n)|((["])(?:\\?+.)*?\4)|(\s*=\s*)|(;)/).each do |m|
        idx = m.index { |x| x }
        yield TOKENS[idx], m[idx].strip
      end
    end
  end
end
