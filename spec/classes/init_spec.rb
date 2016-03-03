require 'spec_helper'

describe 'cups' do
  context 'on an operating system from the Debian family' do
    let(:facts) { { osfamily: 'Debian' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').with(ensure: 'absent') }
    end
  end

  context 'on an operating system from the RedHat family' do
    let(:facts) { { osfamily: 'RedHat' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_package('cups-ipptool').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').with(ensure: 'absent') }
    end
  end

  context 'on an operating system from the Suse family' do
    let(:facts) { { osfamily: 'Suse' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').with(ensure: 'absent') }
    end
  end

  context 'on any other operating system' do
    let(:facts) { { osfamily: 'Unknown' } }

    context 'with defaults for all parameters' do
      it { expect { should compile }.to raise_error(/operating system/) }
    end

    context "with packages = ['custom-cups', 'custom-ipptool'] and services not specified" do
      let(:params) { { packages: ['custom-cups', 'custom-ipptool'] } }

      it { expect { should compile }.to raise_error(/operating system/) }
    end

    context 'with packages = [] and services = []' do
      let(:params) do
        {
          packages: [],
          services: []
        }
      end

      it { should compile }
    end

    context "with packages = ['custom-cups', 'custom-ipptool'] and services = []" do
      let(:params) do
        {
          packages: ['custom-cups', 'custom-ipptool'],
          services: []
        }
      end

      it { is_expected.to contain_package('custom-cups').with(ensure: 'present') }

      it { is_expected.to contain_package('custom-ipptool').with(ensure: 'present') }
    end

    context "with packages = ['custom-cups', 'custom-ipptool'] and services = ['cupsd', 'cups-browsed']" do
      let(:params) do
        {
          packages: ['custom-cups', 'custom-ipptool'],
          services: ['cupsd', 'cups-browsed']
        }
      end

      it { is_expected.to contain_package('custom-cups').with(ensure: 'present') }

      it { is_expected.to contain_package('custom-ipptool').with(ensure: 'present') }

      it { is_expected.to contain_service('cupsd').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_service('cupsd').that_requires('Package[custom-cups]') }

      it { is_expected.to contain_service('cupsd').that_requires('Package[custom-ipptool]') }

      it { is_expected.to contain_service('cups-browsed').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_service('cups-browsed').that_requires('Package[custom-cups]') }

      it { is_expected.to contain_service('cups-browsed').that_requires('Package[custom-ipptool]') }
    end
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

    describe 'packages' do
      context '= undef' do
        let(:facts) { { osfamily: 'Unknown' } }

        it { expect { should compile }.to raise_error(/packages/) }
      end

      context '= []' do
        let(:params) { { packages: [] } }

        it { should_not contain_package('cups') }
      end

      context "= 'custom-cups'" do
        let(:params) { { packages: 'custom-cups' } }

        it { is_expected.to contain_package('custom-cups').with(ensure: 'present') }
      end

      context "= ['custom-cups', 'custom-ipptool']" do
        let(:params) { { packages: ['custom-cups', 'custom-ipptool'] } }

        it { is_expected.to contain_package('custom-cups').with(ensure: 'present') }

        it { is_expected.to contain_package('custom-ipptool').with(ensure: 'present') }
      end
    end

    describe 'services' do
      context '= undef' do
        let(:facts) { { osfamily: 'Unknown' } }
        let(:params) { { packages: 'cupsd' } }

        it { expect { should compile }.to raise_error(/services/) }
      end

      context '= []' do
        let(:params) { { services: [] } }

        it { should_not contain_service('cups') }
      end

      context "= 'cupsd' and packages = 'cupsd'" do
        let(:params) do
          {
            packages: 'custom-cups',
            services: 'cupsd'
          }
        end

        it { is_expected.to contain_service('cupsd').with(ensure: 'running', enable: 'true') }

        it { is_expected.to contain_service('cupsd').that_requires('Package[custom-cups]') }
      end

      context "= ['cupsd', 'cups-browsed'] and packages = ['custom-cups', 'custom-ipptool']" do
        let(:params) do
          {
            packages: ['custom-cups', 'custom-ipptool'],
            services: ['cupsd', 'cups-browsed']
          }
        end

        it { is_expected.to contain_service('cupsd').with(ensure: 'running', enable: 'true') }

        it { is_expected.to contain_service('cupsd').that_requires('Package[custom-cups]') }

        it { is_expected.to contain_service('cupsd').that_requires('Package[custom-ipptool]') }

        it { is_expected.to contain_service('cups-browsed').with(ensure: 'running', enable: 'true') }

        it { is_expected.to contain_service('cups-browsed').that_requires('Package[custom-cups]') }

        it { is_expected.to contain_service('cups-browsed').that_requires('Package[custom-ipptool]') }
      end

      context "when packages = 'undef' and services = 'cupsd'" do
        let(:params) do
          {
            packages: 'undef',
            services: 'cupsd'
          }
        end

        it { is_expected.to contain_service('cupsd').with(ensure: 'running', enable: 'true') }

        it { is_expected.not_to contain_service('cupsd').that_requires('Package[cups]') }
      end
    end

    describe 'webinterface' do
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
