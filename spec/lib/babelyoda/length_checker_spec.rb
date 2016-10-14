require 'babelyoda/keyset'
require 'babelyoda/length_checker'
require 'babelyoda/length_checker_params'
require 'babelyoda/strings_lexer'
require 'babelyoda/strings_parser'

describe "length checker" do
  before(:example) do
    @ratio = 2
    @delta = 3
    @params = Babelyoda::LengthCheckerParams.new()
    @params.ratio = @ratio
    @params.delta = @delta
    @dev_lang = :dev_lang
    @lang1 = :lang1
    @lang2 = :lang2
    @checker = Babelyoda::LengthChecker.new(@dev_lang, @params)
  end
  
  describe "finding long translations in keyset" do
    def add_lang_strings_to_keyset(lang, strings, keyset)
      lexer = Babelyoda::StringsLexer.new    
      parser = Babelyoda::StringsParser.new(lexer, lang)
      parser.parse(strings) do |record|
        keyset.merge_key!(record)
      end
    end
    
    def generate_keyset(dev_str, lang1_str, lang2_str)
      keyset = Babelyoda::Keyset.new("test_keyset")
      add_lang_strings_to_keyset(@dev_lang, dev_str, keyset)
      add_lang_strings_to_keyset(@lang1, lang1_str, keyset)
      add_lang_strings_to_keyset(@lang2, lang2_str, keyset)
      keyset
    end
    
    it "doesn't find anything in empty keyset" do
      empty_keyset = Babelyoda::Keyset.new("empty_keyset")
      
      expect(@checker.long_translations(empty_keyset)).to be_empty
    end
    
    context "when has only non-plural keys" do 
      it "finds long translations" do
        dev_str = <<-EOF 
        /* comment hi */
        "Hi" = "Hi";
        /* comment hello */
        "Hello" = "Hello";
        EOF
        
        lang1_str = <<-EOF 
        /* comment hi */
        "Hi" = "HiHi";
        /* comment hello */
        "Hello" = "HelloHello";
        EOF
        
        lang2_str = <<-EOF 
        /* comment hi */
        "Hi" = "HiHiHiHi";
        /* comment hello */
        "Hello" = "HelloHelloHello";
        EOF
        
        keyset = generate_keyset(dev_str, lang1_str, lang2_str)
        lang1_hello_problem = Babelyoda::LongTranslation.new("Hello", "HelloHello", "comment hello")
        lang2_hi_problem = Babelyoda::LongTranslation.new("Hi", "HiHiHiHi", "comment hi")
        lang2_hello_problem = Babelyoda::LongTranslation.new("Hello", "HelloHelloHello", "comment hello")
        expected = {}
        expected[@lang1] = [lang1_hello_problem]
        expected[@lang2] = [lang2_hi_problem, lang2_hello_problem]
      
        expect(@checker.long_translations(keyset)).to eq(expected) 
      end
    end
    
    context "when has plural keys" do
      it "compares longest plural variants" do
        dev_str = <<-EOF
        /* comment min */
        "%[one]u min" = "min";
        "%[many]u min" = "minutes";
        EOF
        
        lang1_str = <<-EOF
        /* comment min */
        "%[one]u min" = "minminmin";
        "%[many]u min" = "minutes";
        EOF
        
        lang2_str = <<-EOF
        /* comment min */
        "%[one]u min" = "minminmin";
        "%[many]u min" = "minutesminutes";
        EOF
        
        keyset = generate_keyset(dev_str, lang1_str, lang2_str)
        lang2_problem = Babelyoda::LongTranslation.new("minutes", "minutesminutes", "comment min")
        expected = {@lang2 => [lang2_problem]}
        
        expect(@checker.long_translations(keyset)).to eq(expected)  
      end
    end
  end
end
