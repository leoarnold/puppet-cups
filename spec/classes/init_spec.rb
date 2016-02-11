require 'spec_helper'

describe 'cups' do
  context 'on an operating system from the Debian family' do
    let(:facts) { { osfamily: 'Debian' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }
    end
  end

  context 'on an operating system from the RedHat family' do
    let(:facts) { { osfamily: 'RedHat' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_package('cups-ipptool').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }
    end
  end

  context 'on an operating system from the Suse family' do
    let(:facts) { { osfamily: 'Suse' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }
    end
  end

  context 'on any other operating system' do
    it { expect { should compile }.to raise_error(/operating system/) }
  end
end
