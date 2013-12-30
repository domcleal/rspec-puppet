require 'spec_helper'

# Exercises resource testing features of rspec-puppet against the class under
# spec/fixtures/module/sshd/manifests/init.pp
describe 'sshd' do
  # Basic rspec-puppet example
  it 'should have an augeas resource' do
    should contain_augeas('root login')
  end

  # Basic resource test, uses all fixtures
  describe 'specify target+lens upfront, use all fixtures' do
    describe_resource 'Augeas[root login]', :target => 'etc/ssh/sshd_config' do
      it 'should test resource' do
        # Verify this is the right fixture
        open_target { |f| f.readline.should =~ /OpenBSD/ }

        # Check it changes
        should execute.with_change
        open_target { |f| f.read.should =~ /^PermitRootLogin\s+yes$/ }

        # Idempotency test last, as a broken resource may cause false positives
        should execute.idempotently
      end
    end
  end

  # Example of using a second fixture file to test a resource
  describe 'specify target and non-standard fixture' do
    describe_resource 'Augeas[root login]', :target => 'etc/ssh/sshd_config', :fixture => 'etc/ssh/sshd_config_2' do
      it 'should test resource with second fixture' do
        open_target { |f| f.readline.should =~ /Fixture 2/ }
        should execute.with_change
        open_target { |f| f.read.should =~ /^PermitRootLogin\s+yes$/ }
        should execute.idempotently
      end
    end
  end

  # Fixtures can be a hash of destination path to source fixture path
  # Note that all paths are relative to resource_fixtures (in spec_helper.rb)
  # and have no leading /
  describe 'Augeas[specify fixtures as a hash]' do
    describe_resource 'Augeas[root login]', :target => 'etc/ssh/sshd_config', :fixture => { 'etc/ssh/sshd_config' => 'etc/ssh/sshd_config_2' } do
      it 'should test resource with second fixture' do
        open_target { |f| f.readline.should =~ /Fixture 2/ }
        should execute.with_change
        open_target { |f| f.read.should =~ /^PermitRootLogin\s+yes$/ }
        should execute.idempotently
      end
    end
  end

  # Testing for deliberate failure
  describe_resource 'Augeas[fail to add root login]' do
    it 'should fail to run entirely' do
      # Deliberate failure means this is inverted with "not"
      should_not execute

      # Verify the matcher message contains logs
      e = execute
      e.matches? subject
      e.description.should =~ /execute/
      e.failure_message_for_should.should =~ /^err:.*false/
      e.failure_message_for_should_not.should =~ /^err:.*false/
      # Check for debug logs
      e.failure_message_for_should.should =~ /^debug:.*Opening augeas/
      # Ignore transaction stuff
      e.failure_message_for_should.split("\n").grep(/Finishing transaction/).empty?.should be_true
    end
  end

  # Testing for deliberate no-op
  run_resource 'Augeas[make no change]' do
    it 'should fail on with_change' do
      should_not execute.with_change

      # Verify the matcher message contains logs
      e = execute
      e.with_change.matches? subject
      e.description.should =~ /change successfully/
      e.failure_message_for_should.should =~ /doesn't change/
      e.failure_message_for_should_not.should =~ /changes/
    end

    it 'should be considered idempotent' do
      should execute.idempotently
    end

    it 'should fail with both with_change and idempotently' do
      should_not execute.with_change.idempotently

      # Verify the matcher message contains logs
      e = execute
      e.with_change.idempotently.matches? subject
      e.description.should =~ /change once only/
      e.failure_message_for_should.should =~ /doesn't change/
      e.failure_message_for_should_not.should =~ /changes/
    end
  end

  # Testing for deliberate idempotency failure
  run_resource 'Augeas[add root login]', :lens => 'Sshd', :target => 'etc/ssh/sshd_config' do
    it 'should fail on idempotency' do
      should execute.with_change
      open_target { |f| f.each_line.find_all { |l| l =~ /^PermitRootLogin/ }.size.should == 2 }
      should_not execute.idempotently

      # Verify the matcher message contains logs
      e = execute
      e.idempotently.matches? subject
      e.description.should =~ /change at most once/
      e.failure_message_for_should.should =~ /^notice:.*success/
      e.failure_message_for_should_not.should =~ /^notice:.*success/
    end
  end
end
