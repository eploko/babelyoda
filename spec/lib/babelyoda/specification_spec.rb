require 'babelyoda/specification'

describe "specification" do
  it "should specify plain text keys by default" do
    spec = Babelyoda::Specification.new
    spec.plain_text_keys.should == true
  end
end
