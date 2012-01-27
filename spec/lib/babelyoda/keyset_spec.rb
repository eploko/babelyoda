require 'babelyoda/strings_lexer'
require 'babelyoda/strings_parser'
require 'babelyoda/keyset'

describe "keyset" do
  it "can be created" do
    keyset = Babelyoda::Keyset.new('Combined')
    keyset.name.should == 'Combined'
    keyset.keys.size.should == 0
  end
  
  it "should correctly merge plural keys" do
    lexer = Babelyoda::StringsLexer.new    
    parser = Babelyoda::StringsParser.new(lexer, :en)
    str = <<-EOF
    /* Some comment */
    "Some plural %[one]u key" = "Some translation for one %u";
    /* Some comment */
    "Some plural %[some]u key" = "Some translation for some %u";
    /* Some comment */
    "Some plural %[many]u key" = "Some translation for many %u";
    /* Some comment */
    "Some plural %[none]u key" = "Some translation for none %u";
    EOF
    keyset = Babelyoda::Keyset.new('Combined')
    parser.parse(str) do |record|
      keyset.merge_key!(record)
    end
    keyset.keys.size.should == 1
    key = keyset.keys['Some plural %[plural]u key']
    key.should_not == nil
    key.id.should == 'Some plural %[plural]u key'
    key.values.size.should == 1
    value = key.values[:en]
    value.should_not == nil
    value.plural?.should == true
    text = value.text
    text[:one].should == 'Some translation for one %u'
    text[:some].should == 'Some translation for some %u'
    text[:many].should == 'Some translation for many %u'
    text[:none].should == 'Some translation for none %u'
  end
end
