# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'cups' do
  context 'with default values for all attributes' do
    let(:facts) { any_supported_os }

    let(:defaults) do
      {
        listen: ['localhost:631', '/var/run/cups/cups.sock'],
        package_ensure: 'present',
        package_manage: 'true',
        purge_unmanaged_queues: 'false',
        service_enable: 'true',
        service_ensure: 'running',
        service_manage: 'true',
        service_names: 'cups'
      }
    end

    let(:undefs) do
      %i[
        default_queue
        papersize
        resources
        web_interface
      ]
    end

    it { should contain_class('cups::params') }

    it { should contain_class('cups').with(defaults) }

    it { should contain_class('cups').without(undefs) }

    it { should contain_class('cups::packages') }

    it { should contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }

    it do
      should contain_file('/etc/cups/cupsd.conf')
        .with(ensure: 'file', owner: 'root', group: 'lp', mode: '0640', content: /\A#.*DO NOT EDIT/)
    end

    it { should contain_class('cups::server').that_requires('Class[cups::packages]') }

    it { should contain_class('cups::queues').that_requires('Class[cups::server]') }
  end

  context 'with attribute' do
    describe 'default_queue' do
      let(:facts) { any_supported_os }

      context 'when not provided' do
        it { should_not contain_exec('cups::queues::default') }
      end

      context "when set to 'Office'" do
        let(:params) { { default_queue: 'Office' } }

        context "when the catalog does NOT contain the corresponding 'cups_queue' resource" do
          it { should_not compile }
        end

        context "when the catalog contains the corresponding 'cups_queue' resource" do
          let(:pre_condition) { "cups_queue { 'Office':  ensure => 'printer' }" }

          it { should contain_exec('cups::queues::default').with(command: "lpadmin -E -d 'Office'") }

          it { should contain_exec('cups::queues::default').with(unless: "lpstat -d | grep -w 'Office'") }

          it { should contain_exec('cups::queues::default').that_requires('Cups_queue[Office]') }
        end
      end
    end

    describe 'listen' do
      let(:facts) { any_supported_os }

      describe 'by default' do
        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:631$/) }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: %r{^Listen /var/run/cups/cups.sock$}) }
      end

      context "when set to '*:631'" do
        let(:params) { { listen: '*:631' } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen \*:631$/) }
      end

      context "when set to ['*:631', 'localhost:8080']" do
        let(:params) { { listen: ['*:631', 'localhost:8080'] } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen \*:631$/) }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:8080$/) }
      end
    end

    describe 'package_manage' do
      context 'when set to true' do
        context 'with default package_names' do
          on_supported_os.each do |os, facts|
            %w[present absent].each do |package_ensure|
              context "when package_ensure => #{package_ensure}" do
                let(:params) { { package_ensure: package_ensure, package_manage: true } }

                context "on #{os}" do
                  let(:facts) { facts }

                  it { should contain_package('cups').with(ensure: package_ensure) }

                  case facts[:os]['family']
                  when 'Debian'
                    case facts[:os]['name']
                    when 'Debian'
                      if facts[:os]['release']['major'].to_f < 9
                        it { should_not contain_package('cups-ipp-utils') }
                      else
                        it { should contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    when 'Ubuntu'
                      if facts[:os]['release']['major'].to_f < 15.10
                        it { should_not contain_package('cups-ipp-utils') }
                      else
                        it { should contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    when 'LinuxMint'
                      if facts[:os]['release']['major'].to_f < 18
                        it { should_not contain_package('cups-ipp-utils') }
                      else
                        it { should contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    end
                  when 'RedHat'
                    it { should contain_package('cups-ipptool').with(ensure: package_ensure) }
                  end
                end
              end
            end
          end
        end

        context "when package_names = 'mycupsipp'" do
          %w[present absent].each do |package_ensure|
            context "when package_ensure => #{package_ensure}" do
              let(:facts) { any_supported_os }

              let(:params) do
                {
                  package_ensure: package_ensure,
                  package_manage: true,
                  package_names: 'mycupsipp'
                }
              end

              it { should contain_package('mycupsipp').with(ensure: package_ensure) }
            end
          end
        end

        context "when package_names = ['mycups', 'myipp']" do
          %w[present absent].each do |package_ensure|
            context "when package_ensure => #{package_ensure}" do
              let(:facts) { any_supported_os }

              let(:params) do
                {
                  package_ensure: package_ensure,
                  package_manage: true,
                  package_names: %w[mycups myipp]
                }
              end

              it { should contain_package('mycups').with(ensure: package_ensure) }

              it { should contain_package('myipp').with(ensure: package_ensure) }
            end
          end
        end
      end

      context 'when set to false' do
        let(:params) { { package_manage: false } }

        context 'with default package_names' do
          on_supported_os.each do |os, facts|
            context "on #{os}" do
              let(:facts) { facts }

              it { should_not contain_package('cups') }

              it { should_not contain_package('cups-ipp-utils') }

              it { should_not contain_package('cups-ipptool') }
            end
          end
        end

        context "when package_names = ['mycups', 'myipp']" do
          let(:facts) { any_supported_os }

          let(:params) { { package_manage: false, package_names: %w[mycups myipp] } }

          it { should_not contain_package('mycups') }

          it { should_not contain_package('myipp') }
        end
      end
    end

    describe 'papersize' do
      let(:facts) { any_supported_os }

      context 'when set to undef' do
        it { should_not contain_exec('cups::papersize') }
      end

      context 'when set to a4' do
        let(:params) { { papersize: 'a4' } }

        it { should contain_exec('cups::papersize').with(command: 'paperconfig -p a4') }

        it { should contain_exec('cups::papersize').with(unless: 'cat /etc/papersize | grep -w a4') }
      end
    end

    describe 'purge_unmanaged_queues' do
      let(:facts) { any_supported_os }

      context 'when set to true' do
        let(:params) { { purge_unmanaged_queues: true } }

        it { should contain_resources('cups_queue').with(purge: 'true') }
      end

      context 'when set to false' do
        let(:params) { { purge_unmanaged_queues: false } }

        it { should contain_resources('cups_queue').with(purge: 'false') }
      end
    end

    describe 'resources' do
      let(:facts) { any_supported_os }

      context "when set to { 'BackOffice' => { 'ensure' => 'printer' }, UpperFloor' => { 'ensure' => 'class', 'members' => ['BackOffice'] }" do
        let(:params) do
          {
            resources: {
              'BackOffice' => { 'ensure' => 'printer' },
              'UpperFloor' => { 'ensure' => 'class', 'members' => ['BackOffice'] }
            }
          }
        end

        it { should contain_cups_queue('BackOffice').with(ensure: 'printer') }

        it { should contain_cups_queue('UpperFloor').with(ensure: 'class', members: ['BackOffice']) }
      end
    end

    describe 'service_manage' do
      let(:facts) { any_supported_os }

      context 'when set to true' do
        context "with service_names => 'mycups'," do
          %w[running stopped].each do |service_ensure|
            context "service_ensure => #{service_ensure}" do
              [true, false].each do |service_enable|
                context "and service_enable => #{service_enable}" do
                  let(:params) do
                    {
                      service_enable: service_enable,
                      service_ensure: service_ensure,
                      service_manage: true,
                      service_names: 'mycups'
                    }
                  end

                  it { should contain_service('mycups').with(ensure: service_ensure, enable: service_enable) }
                end
              end
            end
          end
        end

        context "with service_names => ['mycups', 'mycups-browsed']," do
          %w[running stopped].each do |service_ensure|
            context "service_ensure => #{service_ensure}" do
              [true, false].each do |service_enable|
                context "and service_enable => #{service_enable}" do
                  let(:params) do
                    {
                      service_enable: service_enable,
                      service_ensure: service_ensure,
                      service_manage: true,
                      service_names: %w[mycups mycups-browsed]
                    }
                  end

                  it { should contain_service('mycups').with(ensure: service_ensure, enable: service_enable) }

                  it { should contain_service('mycups-browsed').with(ensure: service_ensure, enable: service_enable) }
                end
              end
            end
          end
        end
      end

      context 'when set to false' do
        %w[cups mycups].each do |service_names|
          context "with service_names => #{service_names}," do
            let(:params) { { service_manage: false, service_names: service_names } }

            it { should_not contain_service(service_names) }
          end
        end
      end

      context "when service_names = 'mycups'" do
        %w[present absent].each do |service_ensure|
          context "when service_ensure => #{service_ensure}" do
            let(:facts) { any_supported_os }

            let(:params) do
              {
                service_ensure: service_ensure,
                service_manage: false,
                service_names: 'mycups'
              }
            end

            it { should_not contain_service('mycups') }
          end
        end
      end
    end

    describe 'web_interface' do
      let(:facts) { any_supported_os }

      context 'when set to true' do
        let(:params) { { web_interface: true } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface Yes$/) }
      end

      context 'when set to false' do
        let(:params) { { web_interface: false } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface No$/) }
      end
    end
  end
end
