require 'rspec-puppet/matchers/create_generic'
require 'rspec-puppet/matchers/include_class'
require 'rspec-puppet/matchers/compile'
require 'rspec-puppet/matchers/run'
require 'rspec-puppet/matchers/count_generic'
require 'rspec-puppet/matchers/dynamic_matchers'
require 'rspec-puppet/matchers/execute'

RSpec::configure do |c|
  c.include RSpec::Puppet::Matchers, :type => :resource
end
