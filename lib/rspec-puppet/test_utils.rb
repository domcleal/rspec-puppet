require 'tempfile'

module RSpec::Puppet
  module TestUtils
    def open_target(opts = {})
      file = opts[:target] || self.target or raise ArgumentError, ":target must be supplied"
      f = File.open(File.join(self.output_root, file))
      return f unless block_given?
      yield f
      f.close
    end
  end
end
