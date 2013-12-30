require 'rspec-puppet/resource'
require 'tempfile'

module RSpec::Puppet
  module ResourceExampleGroup

    module ClassMethods
      # new example group, much like 'describe'
      #   title (arg #1) must match resource name, e.g. File[/foo]
      #   args may be hash containing:
      #     :fixture =>
      #       String -> relative path of source fixture file
      #       Hash   -> { "/dest/path" => "source/fixture/path", ... }
      def run_resource(*args, &block)
        options = args.last.is_a?(::Hash) ? args.pop : {}
        args << { :type => :resource }
        title = args.shift

        describe(title, *args) do
          # inside here (the resource type block), subject will be initialised
          # to the resource object

          # initialise arguments passed into the run_resource block
          target = options.delete(:target)
          let(:target) { target }

          fixture = options.delete(:fixture)
          let(:fixture) do
            if fixture and !fixture.is_a? Hash
              raise ArgumentError, ":target must be supplied" unless self.target
              fixture = { self.target => fixture.to_s }
            end
            fixture
          end

          class_exec(&block)
        end
      end

      # Synonym for run_resource
      def describe_resource(*args, &block)
        run_resource(*args, &block)
      end
    end

    module InstanceMethods
      # Requires that the title of this example group is the resource title and
      # that the parent example group subject provides a catalogue
      def resource
        unless @resource
          title = self.class.description
          raise ArgumentError, "title must be Type[title] style" unless title =~ /\A([^\[]+)\[(.*)\]\z/
          @resource = catalogue.resource($1, $2)
        end
        @resource
      end

      # Initialises the implicit example group 'subject' to a wrapped resource
      def subject
        @subject ||= Resource.new(self.resource, fixture)
      end

      def output_root
        subject.root
      end

      def open_target(opts = {})
        file = opts[:target] || self.target or raise ArgumentError, ":target must be supplied"
        f = File.open(File.join(self.output_root, file))
        return f unless block_given?
        yield f
        f.close
      end
    end
  end
end
