require 'babelyoda/strings_lexer'
require 'babelyoda/strings_parser'

describe "strings parser" do
  before(:each) do
    @lexer = Babelyoda::StringsLexer.new    
  end
  
  it "can be created" do
    parser = Babelyoda::StringsParser.new(@lexer, :en)
  end
  
  context "parsing" do
    before(:each) do
      @parser = Babelyoda::StringsParser.new(@lexer, :en)
    end
    
    it "should parse simple keys" do
      str = <<-EOF
      /* Some comment */
      "Some key" = "Some translation";
      EOF
      result = []
      @parser.parse(str) do |record|
        result << record
      end
      result.size.should == 1
      result[0].context.should == "Some comment"
      result[0].id.should == "Some key"
      result[0].values.size.should == 1
      result[0].plural?.should == false
      result[0].values[:en].language.should == :en
      result[0].values[:en].status.should == :requires_translation
      result[0].values[:en].text.should == "Some translation"
    end

    it "should parse plural keys" do
      str = <<-EOF
      // Some comment
      "%[one]d organizations" = "%[one]d organizations";
      EOF
      result = []
      @parser.parse(str) do |record|
        result << record
      end
      result.size.should == 1
      result[0].context.should == "Some comment"
      result[0].id.should == "%[plural]d organizations"
      result[0].values.size.should == 1
      result[0].plural?.should == true
      result[0].values[:en].language.should == :en
      result[0].values[:en].status.should == :requires_translation
      result[0].values[:en].text[:one].should == "%d organizations"
    end
  end
  
end
