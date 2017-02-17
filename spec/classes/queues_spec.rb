require 'spec_helper'

describe 'cups::queues' do
  context 'with default values for all parameters' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { should contain_class('cups::queues::default') }

        it { should contain_class('cups::queues::unmanaged') }
      end
    end
  end
end
