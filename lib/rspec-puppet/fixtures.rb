require 'tempfile'
require 'tmpdir'

module RSpec::Puppet
  module Fixtures
    # Copies test fixtures to a temporary directory
    # If file is nil, copies the entire resource_fixtures directory
    # If file is a hash, it copies the "value" from resource_fixtures
    #   to each "key" path
    def load_fixtures(resource, file)
      if block_given?
        Dir.mktmpdir("rspec-puppet") do |dir|
          prepare_fixtures(dir, resource, file)
          yield dir
        end
      else
        dir = Dir.mktmpdir("rspec-puppet")
        prepare_fixtures(dir, resource, file)
        dir
      end
    end

    def prepare_fixtures(dir, resource, file)
      if file.nil?
        FileUtils.cp_r File.join(RSpec.configuration.resource_fixtures, "."), dir
      else
        file.each do |dest,src|
          FileUtils.mkdir_p File.join(dir, File.dirname(dest))
          src = File.join(RSpec.configuration.resource_fixtures, src) unless src.start_with? File::SEPARATOR
          FileUtils.cp_r src, File.join(dir, dest)
        end
      end
    end

    # Runs a particular resource via a catalog and stores logs in the caller's
    # supplied array
    def apply(resource, logs)
      logs.clear
      Puppet::Util::Log.newdestination(Puppet::Test::LogCollector.new(logs))
      Puppet::Util::Log.level = 'debug'

      [:require, :before, :notify, :subscribe].each { |p| resource.delete p }
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource
      catalog = catalog.to_ral if resource.is_a? Puppet::Resource
      txn = catalog.apply

      Puppet::Util::Log.close_all
      txn
    end
  end
end
