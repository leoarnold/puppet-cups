require 'spec_helper'
describe 'cups' do

  context 'with defaults for all parameters' do
    it { should contain_class('cups') }
  end
end
