module RSpec::Puppet
  module HostExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      load_catalogue(:host)
    end
  end
end
