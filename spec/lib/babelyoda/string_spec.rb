require 'babelyoda/string'

describe "string" do
  it "should escape double-quotes" do
    a = '"Starts with quotes", \"these quotes should not be escaped again\", "ends with quotes"'
    a.escape_double_quotes.should == '\"Starts with quotes\", \"these quotes should not be escaped again\", \"ends with quotes\"'
  end
end
