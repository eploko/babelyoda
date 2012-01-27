require 'babelyoda/tanker'

describe "tanker XML serialization" do
  it "should serialize non-plural values" do
    value = Babelyoda::LocalizationValue.new(:en, "Some translation")

    builder = Nokogiri::XML::Builder.new do |xml|
      value.to_xml(xml)
    end

    builder.to_xml.should == "<?xml version=\"1.0\"?>\n<value language=\"en\" status=\"requires_translation\">Some translation</value>\n"
  end

  it "should serialize plural values" do
    value = Babelyoda::LocalizationValue.new(:en, "some plural %u translation")
    value.pluralize!

    builder = Nokogiri::XML::Builder.new do |xml|
      value.to_xml(xml)
    end

    builder.to_xml.should == '<?xml version="1.0"?>' + "\n" +
                             '<value language="en" status="requires_translation">' + "\n" +
                             '  <plural>' + "\n" +
                             '    <one>some plural %u translation</one>' + "\n" +
                             '    <some></some>' + "\n" +
                             '    <many></many>' + "\n" +
                             '    <none></none>' + "\n" +
                             '  </plural>' + "\n" +
                             '</value>' + "\n"
  end

  it "should serialize non-plural keys" do
    key = Babelyoda::LocalizationKey.new("Some key", "Some context")
    value = Babelyoda::LocalizationValue.new(:en, "Some translation")
    key << value

    builder = Nokogiri::XML::Builder.new do |xml|
      key.to_xml(xml)
    end

    builder.to_xml.should == "<?xml version=\"1.0\"?>\n" + 
                             "<key id=\"Some key\" is_plural=\"False\">\n" +
                             "  <context>Some context</context>\n" +
                             "  <value language=\"en\" status=\"requires_translation\">Some translation</value>\n" +
                             "</key>\n"
  end

  it "should serialize plural keys" do
    key = Babelyoda::LocalizationKey.new("Some %[one]d plural key", "Some context")

    value = Babelyoda::LocalizationValue.new(:en, "Some translation for one")
    value.pluralize!(:one)
    key << value

    value = Babelyoda::LocalizationValue.new(:en, "Some translation for some")
    value.pluralize!(:some)
    key << value

    builder = Nokogiri::XML::Builder.new do |xml|
      key.to_xml(xml)
    end

    builder.to_xml.should == 
<<-EOF
<?xml version="1.0"?>
<key id="Some %[plural]d plural key" is_plural="True">
  <context>Some context</context>
  <value language="en" status="requires_translation">
    <plural>
      <one>Some translation for one</one>
      <some>Some translation for some</some>
      <many></many>
      <none></none>
    </plural>
  </value>
</key>
EOF
  end
  
  it "should parse non-plural value" do
    doc = Nokogiri::XML.parse(
      <<-EOF
      <?xml version="1.0"?>
      <value language="en" status="requires_translation">Some translation</value>
      EOF
    )
    value = Babelyoda::LocalizationValue.parse_xml(doc.root)
    value.language.should == :en
    value.status.should == :requires_translation
    value.text.should == 'Some translation'
    value.plural?.should == false
  end

  it "should parse plural value" do
    doc = Nokogiri::XML.parse(
      <<-EOF
      <?xml version="1.0"?>
      <value language="en" status="requires_translation">
        <plural>
          <one>Some translation for one</one>
          <some>Some translation for some</some>
          <many></many>
          <none></none>
        </plural>
      </value>
      EOF
    )
    value = Babelyoda::LocalizationValue.parse_xml(doc.root)
    value.language.should == :en
    value.status.should == :requires_translation
    value.plural?.should == true
    value.text[:one].should == 'Some translation for one'
    value.text[:some].should == 'Some translation for some'
    value.text[:many].should == nil
    value.text[:noen].should == nil
  end

  it "should parse non-plural key" do
    doc = Nokogiri::XML.parse(
      <<-EOF
      <?xml version="1.0"?>
      <key id="Some key" is_plural="False">
        <value language="en" status="requires_translation">Some translation</value>
      </key>
      EOF
    )
    key = Babelyoda::LocalizationKey.parse_xml(doc.root)
    key.id.should == "Some key"
    key.plural?.should == false
    key.values.size.should == 1
    value = key.values[:en]
    value.should_not == nil
    value.text.should == "Some translation"
  end

  it "should parse plural key" do
    doc = Nokogiri::XML.parse(
      <<-EOF
      <?xml version="1.0"?>
      <key id="Some %[plural]d key" is_plural="True">
        <value language="en" status="requires_translation">
          <plural>
            <one>Some translation for %d one</one>
            <some>Some translation for %d some</some>
            <many></many>
            <none></none>
          </plural>
        </value>
      </key>
      EOF
    )
    key = Babelyoda::LocalizationKey.parse_xml(doc.root)
    key.id.should == "Some %[plural]d key"
    key.plural?.should == true
    key.values.size.should == 1
    value = key.values[:en]
    value.should_not == nil
    value.text[:one].should == 'Some translation for %d one'
    value.text[:some].should == 'Some translation for %d some'
    value.text[:many].should == nil
    value.text[:none].should == nil
  end
end
