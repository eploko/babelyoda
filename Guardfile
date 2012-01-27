notification :gntp, :sticky => true, :host => '127.0.0.1', :password => ENV['GNTP_PASS']


guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| ["spec/lib/#{m[1]}_spec.rb"] }
  watch('spec/spec_helper.rb')  { "spec" }
end

