require 'babelyoda/strings'

describe "strings-based keyset" do
  it "can be created with a filename and language" do
    strings = Babelyoda::Strings.new('Combined.strings', :en)
  end
  
  context "when empty" do
    it "serializes to an IO object" do
      strings = Babelyoda::Strings.new('Combined.strings', :en)
      io = StringIO.new
      strings.to_strings(io, :en)
      io.read.should == ''
    end
  end
  
  context "when has only non-plural keys" do
    it "merges keys in" do
      strings = Babelyoda::Strings.new('Combined.strings', :en)
      value = Babelyoda::LocalizationValue.new(:en, 'Some translation')
      key = Babelyoda::LocalizationKey.new('Some key', 'Some comment')
      key << value
      strings.merge_key!(key)
      strings.keys.size.should == 1
    end
    
    it "serializes to an IO object" do
      strings = Babelyoda::Strings.new('Combined.strings', :en)
      
      value = Babelyoda::LocalizationValue.new(:en, 'Some translation')
      key = Babelyoda::LocalizationKey.new('Some key', 'Some comment')
      key << value
      strings.merge_key!(key)
      
      io = StringIO.new
      strings.to_strings(io, :en)
      io.rewind
      io.read.should == 
<<-EOF
/* Some comment */
"Some key" = "Some translation";

EOF
    end
  end
  
  context "with plural keys" do
    it "serializes to an IO object" do
      strings = Babelyoda::Strings.new('Combined.strings', :en)

      value_one = Babelyoda::LocalizationValue.new(:en, 'Some translation for %d one')
      value_some = Babelyoda::LocalizationValue.new(:en, 'Some translation for %d some')
      value_some.pluralize!(:some)
      key = Babelyoda::LocalizationKey.new('Some %[one]d plural key', 'Some comment')
      key << value_one
      key << value_some
      strings.merge_key!(key)

      io = StringIO.new
      strings.to_strings(io, :en)
      io.rewind
      io.read.should == 
<<-EOF
/* Some comment */
"Some %[one]d plural key" = "Some translation for %d one";
"Some %[some]d plural key" = "Some translation for %d some";

EOF
    end
  end
end
