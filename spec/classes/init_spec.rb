# encoding: UTF-8
require 'spec_helper'

describe 'cups' do
  context 'with defaults for all parameters' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { should contain_class('cups').with(purge_unmanaged_queues: 'false') }

        it { should contain_class('cups::params') }

        it { should_not contain_class('cups::default_queue') }

        it { should contain_package('cups').with(ensure: 'present') }

        it { should contain_service('cups').with(ensure: 'running', enable: 'true') }

        it { should contain_service('cups').that_requires('Package[cups]') }

        it { should contain_resources('cups_queue').with(purge: 'false') }

        case facts[:osfamily]
        when 'Debian'
          case facts[:operatingsystem]
          when 'Debian'
            if facts[:operatingsystemmajrelease].to_f < 9
              it { should_not contain_package('cups-ipp-utils') }
            else
              it { should contain_package('cups-ipp-utils') }

              it { should contain_service('cups').that_requires('Package[cups-ipp-utils]') }
            end
          when 'Ubuntu'
            if facts[:operatingsystemmajrelease].to_f < 15.10
              it { should_not contain_package('cups-ipp-utils') }
            else
              it { should contain_package('cups-ipp-utils') }

              it { should contain_service('cups').that_requires('Package[cups-ipp-utils]') }
            end
          when 'LinuxMint'
            if facts[:operatingsystemmajrelease].to_f < 18
              it { should_not contain_package('cups-ipp-utils') }
            else
              it { should contain_package('cups-ipp-utils') }

              it { should contain_service('cups').that_requires('Package[cups-ipp-utils]') }
            end
          end
        when 'RedHat'
          it { should contain_package('cups-ipptool').with(ensure: 'present') }

          it { should contain_service('cups').that_requires('Package[cups-ipptool]') }
        end
      end
    end
  end

  context 'on any other operating system' do
    let(:facts) { { osfamily: 'Unknown' } }

    context 'with defaults for all parameters' do
      it { should_not compile }
    end

    context "with packages = ['custom-cups', 'custom-ipptool'] and services not specified" do
      let(:params) { { packages: ['custom-cups', 'custom-ipptool'] } }

      it { should_not compile }
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

      it { should contain_package('custom-cups').with(ensure: 'present') }

      it { should contain_package('custom-ipptool').with(ensure: 'present') }
    end

    context "with packages = ['custom-cups', 'custom-ipptool'] and services = ['cupsd', 'cups-browsed']" do
      let(:params) do
        {
          packages: ['custom-cups', 'custom-ipptool'],
          services: ['cupsd', 'cups-browsed']
        }
      end

      it { should contain_package('custom-cups').with(ensure: 'present') }

      it { should contain_package('custom-ipptool').with(ensure: 'present') }

      it { should contain_service('cupsd').with(ensure: 'running', enable: 'true') }

      it { should contain_service('cupsd').that_requires('Package[custom-cups]') }

      it { should contain_service('cupsd').that_requires('Package[custom-ipptool]') }

      it { should contain_service('cups-browsed').with(ensure: 'running', enable: 'true') }

      it { should contain_service('cups-browsed').that_requires('Package[custom-cups]') }

      it { should contain_service('cups-browsed').that_requires('Package[custom-ipptool]') }
    end
  end

  context 'OS independent attribute' do
    let(:facts) { { osfamily: 'Suse' } }

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

        it { should contain_exec('lpadmin-d-Office') }
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

        it { should contain_package('custom-cups').with(ensure: 'present') }

        it { should contain_package('custom-ipptool').with(ensure: 'present') }
      end
    end

    describe 'papersize' do
      context '= undef' do
        it { should_not contain_class('cups::papersize') }
      end

      context '= a4' do
        let(:facts) { { osfamily: 'Suse' } }
        let(:params) { { papersize: 'a4' } }

        it { should contain_class('cups::papersize').with(papersize: 'a4') }

        it { should contain_class('cups::papersize').that_requires('Package[cups]') }

        it { should contain_class('cups::papersize').that_notifies('Service[cups]') }

        it { should contain_exec('paperconfig -p a4') }
      end
    end

    describe 'purge_unmanaged_queues' do
      context '= false' do
        it { should contain_resources('cups_queue').with(purge: 'false') }
      end

      context '= true' do
        let(:params) { { purge_unmanaged_queues: true } }

        it { should contain_resources('cups_queue').with(purge: 'true') }
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

        it { should contain_service('cupsd').with(ensure: 'running', enable: 'true') }

        it { should contain_service('cupsd').that_requires('Package[custom-cups]') }

        it { should contain_service('cupsd').that_requires('Package[custom-ipptool]') }

        it { should contain_service('cups-browsed').with(ensure: 'running', enable: 'true') }

        it { should contain_service('cups-browsed').that_requires('Package[custom-cups]') }

        it { should contain_service('cups-browsed').that_requires('Package[custom-ipptool]') }
      end
    end
  end
end
