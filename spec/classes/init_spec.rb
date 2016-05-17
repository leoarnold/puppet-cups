# encoding: UTF-8
require 'spec_helper'

describe 'cups' do
  context 'on an operating system from the Debian family' do
    let(:facts) { { osfamily: 'Debian' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should contain_class('cups::params') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').that_requires('Service[cups]') }

      it { is_expected.to contain_resources('cups_queue').with(purge: 'false') }
    end
  end

  context 'on an operating system from the RedHat family' do
    let(:facts) { { osfamily: 'RedHat' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should contain_class('cups::params') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_package('cups-ipptool').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').that_requires('Service[cups]') }

      it { is_expected.to contain_resources('cups_queue').with(purge: 'false') }
    end
  end

  context 'on an operating system from the Suse family' do
    let(:facts) { { osfamily: 'Suse' } }

    context 'with defaults for all parameters' do
      it { should contain_class('cups').with(confdir: '/etc/cups') }

      it { should contain_class('cups::params') }

      it { should_not contain_class('cups::default_queue') }

      it { is_expected.to contain_package('cups').with(ensure: 'present') }

      it { is_expected.to contain_service('cups').that_requires('Package[cups]') }

      it { is_expected.to contain_service('cups').with(ensure: 'running', enable: 'true') }

      it { is_expected.to contain_file('lpoptions').that_requires('Service[cups]') }

      it { is_expected.to contain_resources('cups_queue').with(purge: 'false') }
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

    describe 'confdir' do
      context 'not provided' do
        it { is_expected.to contain_file('lpoptions').with(ensure: 'absent', path: '/etc/cups/lpoptions') }
      end

      context '= /usr/local/etc/cups' do
        let(:params) { { confdir: '/usr/local/etc/cups' } }

        it { is_expected.to contain_file('lpoptions').with(ensure: 'absent', path: '/usr/local/etc/cups/lpoptions') }
      end
    end

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

        it { should contain_class('cups::default_queue').that_requires('File[lpoptions]') }
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

      context "= ['custom-cups', 'custom-ipptool']" do
        let(:params) { { packages: ['custom-cups', 'custom-ipptool'] } }

        it { is_expected.to contain_package('custom-cups').with(ensure: 'present') }

        it { is_expected.to contain_package('custom-ipptool').with(ensure: 'present') }
      end
    end

    describe 'papersize' do
      context '= undef' do
        it { should_not contain_class('cups::papersize') }
      end

      context '= a4' do
        let(:facts) { { osfamily: 'Debian' } }
        let(:params) { { papersize: 'a4' } }

        it { is_expected.to contain_class('cups::papersize').with(papersize: 'a4') }

        it { is_expected.to contain_class('cups::papersize').that_requires('Package[cups]') }

        it { is_expected.to contain_class('cups::papersize').that_notifies('Service[cups]') }
      end
    end

    describe 'purge_unmanaged_queues' do
      context '= false' do
        it { is_expected.to contain_resources('cups_queue').with(purge: 'false') }
      end

      context '= true' do
        let(:params) { { purge_unmanaged_queues: true } }

        it { is_expected.to contain_resources('cups_queue').with(purge: 'true') }
      end
    end

    describe 'services' do
      context '= undef' do
        let(:facts) { { osfamily: 'Unknown' } }
        let(:params) { { packages: ['cupsd'] } }

        it { expect { should compile }.to raise_error(/services/) }
      end

      context '= []' do
        let(:params) { { services: [] } }

        it { should_not contain_service('cups') }
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
    end

    describe 'webinterface' do
      context 'not provided' do
        it { should_not contain_cups__ctl('WebInterface') }
      end

      context '= true' do
        let(:params) { { webinterface: true } }

        it { is_expected.to contain_cups__ctl('WebInterface').with(ensure: 'Yes') }

        it { is_expected.to contain_exec('cupsctl-WebInterface').with(command: 'cupsctl -E WebInterface=Yes') }
      end

      context '= false' do
        let(:params) { { webinterface: false } }

        it { is_expected.to contain_cups__ctl('WebInterface').with(ensure: 'No') }

        it { is_expected.to contain_exec('cupsctl-WebInterface').with(command: 'cupsctl -E WebInterface=No') }
      end
    end
  end
end
