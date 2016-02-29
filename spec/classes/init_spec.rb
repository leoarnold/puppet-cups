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

      it { is_expected.to contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }
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

      it { is_expected.to contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }
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

      it { is_expected.to contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }
    end
  end

  context 'on any other operating system' do
    it { expect { should compile }.to raise_error(/operating system/) }
  end

  context 'OS independent attribute' do
    let(:facts) { { osfamily: 'Debian' } }

    describe 'default_queue' do
      context 'not provided' do
        it { should_not contain_class('cups::default_queue') }
      end

      context "= 'Office'" do
        let(:pre_condition) do
          <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              model  => 'drv:///sample.drv/generic.ppd',
              uri    => 'lpd://192.168.2.105/binary_p1'
            }
          EOM
        end
        let(:params) { { default_queue: 'Office' } }

        it { should contain_class('cups::default_queue').with(queue: 'Office') }

        it { should contain_exec('lpadmin-d').that_requires('Cups_queue[Office]') }
      end
    end

    context 'with attribute webinterface' do
      context 'not provided' do
        it { should_not contain_cups__directive('WebInterface') }
      end

      context '= true' do
        let(:params) { { webinterface: true } }

        it { is_expected.to contain_cups__directive('WebInterface').with(value: 'Yes') }

        it { is_expected.to contain_exec('cupsctl-WebInterface').with(command: '/usr/sbin/cupsctl WebInterface=Yes') }
      end

      context '= false' do
        let(:params) { { webinterface: false } }

        it { is_expected.to contain_cups__directive('WebInterface').with(value: 'No') }

        it { is_expected.to contain_exec('cupsctl-WebInterface').with(command: '/usr/sbin/cupsctl WebInterface=No') }
      end
    end
  end
end
