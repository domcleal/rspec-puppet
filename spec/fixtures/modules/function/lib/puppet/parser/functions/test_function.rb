module Puppet::Parser::Functions
  newfunction(:test_function, :type => :rvalue) do |*args|
    "Test function"
  end
end
