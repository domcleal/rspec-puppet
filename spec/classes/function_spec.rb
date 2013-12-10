require 'spec_helper'

describe 'function' do
  it { should create_notify("test_function")\
    .with_message("Test function") }
end
