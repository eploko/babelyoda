require 'babelyoda/string'

describe "string" do
  it "should escape double-quotes" do
    a = 'some "key"'
    a.escape_double_quotes.should == "some \\\"key\\\""
  end
end
