module Puppet::Parser::Functions
  newfunction(:test_function2, :type => :rvalue) do |*args|
    "Test function"
  end
end
