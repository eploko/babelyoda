require 'babelyoda/localization_value'

describe "localization value" do
  it "can be created" do
    value = Babelyoda::LocalizationValue.new(:en, "Value 1")
    value.language.should == :en
    value.text.should == "Value 1"
  end
  
  it "should merge non-plural values" do
    value1 = Babelyoda::LocalizationValue.new(:en, "Value 1")
    value2 = Babelyoda::LocalizationValue.new(:en, "Value 2")
    value1.merge!(value2)
    value1.language.should == :en
    value1.text.should == "Value 2"
  end
  
  it "should preserve values if specified so in options and the status != :translation_required" do
    value1 = Babelyoda::LocalizationValue.new(:en, "Value 1")
    value1.status = :translated
    value2 = Babelyoda::LocalizationValue.new(:en, "Value 2")
    value1.merge!(value2, { preserve: true })
    value1.language.should == :en
    value1.text.should == "Value 1"
  end

  it "should preserve values in status :requires_translation if the project uses non plain text keys" do
    value1 = Babelyoda::LocalizationValue.new(:en, "Value 1")
    value2 = Babelyoda::LocalizationValue.new(:en, "Value 2")
    value1.merge!(value2, { preserve: true, plain_text_keys: false })
    value1.language.should == :en
    value1.text.should == "Value 1"
  end
end
