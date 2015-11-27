module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      load_catalogue(:class)
    end
  end
end
