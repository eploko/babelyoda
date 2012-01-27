require "babelyoda/strings_lexer"

describe "strings lexer" do
  it "can be created" do
    lexer = Babelyoda::StringsLexer.new
  end
  
  context "basic strings lexer" do

    before(:each) do
      @lexer = Babelyoda::StringsLexer.new
    end

    it "can parse tokens" do
      str = <<-EOF
      /* Some comment */
      "Some key" = "Some translation";
      EOF
      result = []
      @lexer.lex(str) do |token, value|
        result << { :token => token, :value => value }
      end
      result.size.should == 5
      result[0][:token].should == :multiline_comment
      result[0][:value].should == "/* Some comment */"
      result[1][:token].should == :string
      result[1][:value].should == "\"Some key\""
      result[2][:token].should == :equal_sign
      result[2][:value].should == "="
      result[3][:token].should == :string
      result[3][:value].should == "\"Some translation\""
      result[4][:token].should == :semicolon
      result[4][:value].should == ";"
    end

  end  
end
