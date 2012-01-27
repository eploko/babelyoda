require 'babelyoda/localization_key'
require 'babelyoda/localization_value'

describe "basic localization key" do
  it "can be created" do
    key = Babelyoda::LocalizationKey.new("Hello world!", "Some translator comment")
    key.values.size.should == 0
  end
  
  it "should not be marked as plural" do
    key = Babelyoda::LocalizationKey.new("Hello world!", "Some translator comment")
    key.plural?.should == false
  end

  it "ensures the set of languages is present" do
    key = Babelyoda::LocalizationKey.new("Hello world!", "Some translator comment")
    key.ensure_languages!([:en, :ru])
    [:en, :ru].each do |lang|
      value = key.values[lang]
      value.should_not == nil
      value.plural?.should == false
    end
    [:tr, :uk].each do |lang|
      value = key.values[lang]
      value.should == nil
    end
  end

end

describe "plural localization key" do
  it "can be created with a plural id of [one]" do
    key = Babelyoda::LocalizationKey.new("%[one]d organization nearby", "The number of organizations")
    key.plural?.should == true
    key.id.should == "%[plural]d organization nearby"
  end

  it "can be created with a plural id of [some]" do
    key = Babelyoda::LocalizationKey.new("%[some]d organization nearby", "The number of organizations")
    key.plural?.should == true
    key.id.should == "%[plural]d organization nearby"
  end

  it "can be created with a plural id of [many]" do
    key = Babelyoda::LocalizationKey.new("%[many]d organization nearby", "The number of organizations")
    key.plural?.should == true
    key.id.should == "%[plural]d organization nearby"
  end

  it "can be created with a plural id of [none]" do
    key = Babelyoda::LocalizationKey.new("%[none]d organization nearby", "The number of organizations")
    key.plural?.should == true
    key.id.should == "%[plural]d organization nearby"
  end

  it "%% should be ignored and the key be singular" do
    key = Babelyoda::LocalizationKey.new("%%[none]d organization nearby", "The number of organizations")
    key.plural?.should == false
    key.id.should == "%%[none]d organization nearby"
  end
  
  context "after a pluralized key has been created" do
    
    before(:each) do
      @key = Babelyoda::LocalizationKey.new("%[one]d organization nearby", "The number of organizations")
    end
    
    it "should pluralize given values" do
      value = Babelyoda::LocalizationValue.new(:en, "%[one]d organization nearby")
      @key << value
      @key.values.size.should == 1
      value = @key.values[:en]
      value.plural?.should == true
      value.text.kind_of?(Hash).should == true
    end
    
    it "should merge plural values for different plurals of the same key" do
      value1 = Babelyoda::LocalizationValue.new(:en, "%[one]d organization nearby")
      value2 = Babelyoda::LocalizationValue.new(:en, "%[some]d organization nearby")
      @key << value1
      @key << value2
      @key.values.size.should == 1
      value = @key.values[:en]
      value.plural?.should == true
      value.text[:one].should == '%d organization nearby'
      value.text[:some].should == '%d organization nearby'
      value.text[:many].should == nil
      value.text[:none].should == nil
    end
      
  end
  
  it "should correctly merge non-plural value into the correct plural key :one" do
    key = Babelyoda::LocalizationKey.new("%[one]d organization nearby", "The number of organizations")
    value = Babelyoda::LocalizationValue.new(:en, "%d organization nearby")
    key << value
    value = key.values[:en]
    value.text[:one].should == '%d organization nearby'
  end
  
  it "should correctly merge non-plural value into the correct plural key :some" do
    key = Babelyoda::LocalizationKey.new("%[some]d organization nearby", "The number of organizations")
    value = Babelyoda::LocalizationValue.new(:en, "%d organization nearby")
    key << value
    value = key.values[:en]
    value.text[:some].should == '%d organization nearby'
  end
  
  it "should correctly depluralize the key with the plural key in the middle of the key" do
    key = Babelyoda::LocalizationKey.new("Some plural %[none]u key", "The number of organizations")
    key.id.should == 'Some plural %[plural]u key'
    key.plural?.should == true
  end
  
  it "should correctly depluralize the key with the plural key at the beginning of the key" do
    key = Babelyoda::LocalizationKey.new("%[none]u key", "The number of organizations")
    key.id.should == '%[plural]u key'
    key.plural?.should == true
  end
  
  it "should correctly depluralize the key with the plural key at the end of the key" do
    key = Babelyoda::LocalizationKey.new("the key is %[none]u", "The number of organizations")
    key.id.should == 'the key is %[plural]u'
    key.plural?.should == true
  end
  
  it "should not override a non-empty context with an empty context on merge" do
    key1 = Babelyoda::LocalizationKey.new("the key is %[none]u", "Non empty context")
    key2 = Babelyoda::LocalizationKey.new("the key is %[none]u", "")
    key1.merge!(key2)
    key1.context.should == "Non empty context"
  end

  it "ensures the set of languages is present" do
    key = Babelyoda::LocalizationKey.new("the key is %[none]u", "Non empty context")
    key.ensure_languages!([:en, :ru])
    [:en, :ru].each do |lang|
      value = key.values[lang]
      value.should_not == nil
      value.plural?.should == true
      [:one, :some, :many].each do |plural_key|
        value.text[plural_key].should == nil
      end
      value.text[:none].should == ''
    end
    [:tr, :uk].each do |lang|
      value = key.values[lang]
      value.should == nil
    end
  end
  
end
