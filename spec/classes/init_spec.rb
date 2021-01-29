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
      [
        :default_queue,
        :location,
        :papersize,
        :resources,
        :server_alias,
        :server_name,
        :web_interface
      ]
    end

    it { is_expected.to contain_class('cups::params') }

    it { is_expected.to contain_class('cups').with(defaults) }

    it { is_expected.to contain_class('cups').without(undefs) }

    it { is_expected.to contain_class('cups::packages') }

    it { is_expected.to contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }

    it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(ensure: 'file') }

    it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(owner: 'root') }

    it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(group: 'lp') }

    it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(mode: '0640') }

    it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /\A###\n### This file is managed by Puppet. DO NOT EDIT.\n###\n\n/) }

    it { is_expected.to contain_class('cups::server').that_requires('Class[cups::packages]') }

    it { is_expected.to contain_class('cups::queues').that_requires('Class[cups::server]') }
  end

  context 'with attribute' do
    describe 'access_log_level' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^AccessLogLevel/) }
      end

      context "when set to 'config'" do
        let(:params) { { access_log_level: 'config' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^AccessLogLevel config$/) }
      end
    end

    describe 'browse_dnssd_subtypes' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseDNSSDSubTypes/) }
      end

      context "when set to 'cups'" do
        let(:params) { { browse_dnssd_subtypes: 'cups' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseDNSSDSubTypes_cups$/) }
      end

      context "when set to ['cups', 'print']" do
        let(:params) { { browse_dnssd_subtypes: %w[cups print] } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseDNSSDSubTypes_cups,_print$/) }
      end
    end

    describe 'browse_local_protocols' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseLocalProtocols/) }
      end

      context "when set to 'none'" do
        let(:params) { { browse_local_protocols: ['none'] } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseLocalProtocols none$/) }
      end

      context "when set to ['cups', 'print']" do
        let(:params) { { browse_local_protocols: %w[dnssd ldap] } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseLocalProtocols dnssd ldap$/) }
      end
    end

    describe 'browse_web_if' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseWebIF/) }
      end

      context 'when set to true' do
        let(:params) { { browse_web_if: true } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseWebIF Yes$/) }
      end

      context 'when set to false' do
        let(:params) { { browse_web_if: false } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^BrowseWebIF No$/) }
      end
    end

    describe 'browsing' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Browsing No$/) }
      end

      context 'when set to true' do
        let(:params) { { browsing: true } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Browsing Yes$/) }
      end

      context 'when set to false' do
        let(:params) { { browsing: false } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Browsing No$/) }
      end
    end

    describe 'default_queue' do
      let(:facts) { any_supported_os }

      context 'when not provided' do
        it { is_expected.to_not contain_exec('cups::queues::default') }
      end

      context "when set to 'Office'" do
        let(:params) { { default_queue: 'Office' } }

        context "when the catalog does NOT contain the corresponding 'cups_queue' resource" do
          it { is_expected.to_not compile }
        end

        context "when the catalog contains the corresponding 'cups_queue' resource" do
          let(:pre_condition) { "cups_queue { 'Office':  ensure => 'printer' }" }

          it { is_expected.to contain_exec('cups::queues::default').with(command: "lpadmin -d 'Office'") }

          it { is_expected.to contain_exec('cups::queues::default').with(unless: "lpstat -d | grep -w 'Office'") }

          it { is_expected.to contain_exec('cups::queues::default').that_requires('Cups_queue[Office]') }
        end
      end
    end

    describe 'listen' do
      let(:facts) { any_supported_os }

      describe 'by default' do
        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:631$/) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{^Listen /var/run/cups/cups.sock$}) }
      end

      context "when set to '*:631'" do
        let(:params) { { listen: '*:631' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Listen \*:631$/) }
      end

      context "when set to ['*:631', 'localhost:8080']" do
        let(:params) { { listen: ['*:631', 'localhost:8080'] } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Listen \*:631$/) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:8080$/) }
      end
    end

    describe 'location' do
      let(:facts) { any_supported_os }

      describe 'by default' do
        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location />\s*Order allow,deny\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin>\s*Order allow,deny\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/conf>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/log>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }
      end

      context "when set to 'remote-admin'" do
        let(:params) { { location: 'remote-admin' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location />\s*Order allow,deny\s*Allow @LOCAL\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin>\s*Order allow,deny\s*Allow @LOCAL\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/conf>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*Allow @LOCAL\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/log>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*Allow @LOCAL\s*</Location>}) }
      end

      context "when set to 'share-printers'" do
        let(:params) { { location: 'share-printers' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location />\s*Order allow,deny\s*Allow @LOCAL\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin>\s*Order allow,deny\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/conf>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/log>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }
      end

      context 'when set to a Hash' do
        context 'when the default locations are NOT affected' do
          let(:params) do
            {
              location: {
                '/endpoint' => {
                  'Directive' => 'option1 option2',
                  'Key' => 'value'
                }
              }
            }
          end

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /endpoint>\s*Directive option1 option2\s*Key value\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location />\s*Order allow,deny\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin>\s*Order allow,deny\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/conf>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/log>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }
        end

        context 'when the default locations are affected' do
          let(:params) do
            {
              location: {
                '/' => {
                  'Directive' => 'option1 option2',
                  'Key' => 'value'
                }
              }
            }
          end

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location />\s*Directive option1 option2\s*Key value\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin>\s*Order allow,deny\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/conf>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }

          it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Location /admin/log>\s*AuthType Default\s*Require user @SYSTEM\s*Order allow,deny\s*</Location>}) }
        end
      end
    end

    describe 'policies' do
      let(:facts) { any_supported_os }

      describe 'by default' do
        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Policy default>\s*JobPrivateAccess default\s*JobPrivateValues default\s*SubscriptionPrivateAccess default\s*SubscriptionPrivateValues default\s*<Limit}) }
        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Policy authenticated>\s*JobPrivateAccess default\s*JobPrivateValues default\s*SubscriptionPrivateAccess default\s*SubscriptionPrivateValues default\s*<Limit}) }
      end

      context 'when policy options are overridden' do
        let(:params) { {
          'policies' => {
            'default' => {
              'options' => [
                'JobPrivateAccess default',
                'JobPrivateValues default',
              ],
            },
            'authenticated' => {
              'options' => [
                'SubscriptionPrivateAccess default',
                'SubscriptionPrivateValues default',
              ],
            }
          }
        } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Policy default>\s*JobPrivateAccess default\s*JobPrivateValues default\s*<Limit}) }
        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Policy authenticated>\s*SubscriptionPrivateAccess default\s*SubscriptionPrivateValues default\s*<Limit}) }
      end

      context 'when policy options are overridden' do
        let(:params) { {
          'policies' => {
            'default' => {
              'limits' => {
                'Create-Job Print-Job Print-URI Validate-Job' => [
                  'Require user @OWNER @SYSTEM',
                  'Order deny,allow'
                ],
              }
            }
          }
        } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: %r{<Limit\s*Create-Job\s*Print-Job\s*Print-URI\s*Validate-Job>\s*Require\s*user\s*@OWNER\s*@SYSTEM\s*Order\s*deny,allow\s*</Limit>}) }
      end
    end

    describe 'log_debug_history' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^LogDebugHistory/) }
      end

      context 'when set to 5' do
        let(:params) { { log_debug_history: 5 } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^LogDebugHistory 5$/) }
      end
    end

    describe 'log_level' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^LogLevel/) }
      end

      context "when set to 'debug2'" do
        let(:params) { { log_level: 'debug2' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^LogLevel debug2$/) }
      end
    end

    describe 'log_time_format' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^LogTimeFormat/) }
      end

      context "when set to 'usecs'" do
        let(:params) { { log_time_format: 'usecs' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^LogTimeFormat usecs$/) }
      end
    end

    describe 'max_clients' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^MaxClients/) }
      end

      context 'when set to 200' do
        let(:params) { { max_clients: 200 } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^MaxClients 200$/) }
      end
    end

    describe 'max_clients_per_host' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^MaxClientsPerHost/) }
      end

      context 'when set to 200' do
        let(:params) { { max_clients_per_host: 200 } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^MaxClientsPerHost 200$/) }
      end
    end

    describe 'max_log_size' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^MaxLogSize/) }
      end

      context 'when set to 0' do
        let(:params) { { max_log_size: 0 } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^MaxLogSize 0$/) }
      end

      context 'when set to 32m' do
        let(:params) { { max_log_size: '32m' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^MaxLogSize 32m$/) }
      end
    end

    describe 'max_request_size' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^MaxRequestSize/) }
      end

      context 'when set to 200' do
        let(:params) { { max_request_size: 200 } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^MaxRequestSize 200$/) }
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

                  it { is_expected.to contain_package('cups').with(ensure: package_ensure) }

                  case facts[:os]['family']
                  when 'Debian'
                    case facts[:os]['name']
                    when 'Debian'
                      if facts[:os]['release']['major'].to_f < 9
                        it { is_expected.to_not contain_package('cups-ipp-utils') }
                      else
                        it { is_expected.to contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    when 'Ubuntu'
                      if facts[:os]['release']['major'].to_f < 15.10
                        it { is_expected.to_not contain_package('cups-ipp-utils') }
                      else
                        it { is_expected.to contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    when 'LinuxMint'
                      if facts[:os]['release']['major'].to_f < 18
                        it { is_expected.to_not contain_package('cups-ipp-utils') }
                      else
                        it { is_expected.to contain_package('cups-ipp-utils').with(ensure: package_ensure) }
                      end
                    end
                  when 'RedHat'
                    it { is_expected.to contain_package('cups-ipptool').with(ensure: package_ensure) }
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

              it { is_expected.to contain_package('mycupsipp').with(ensure: package_ensure) }
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

              it { is_expected.to contain_package('mycups').with(ensure: package_ensure) }

              it { is_expected.to contain_package('myipp').with(ensure: package_ensure) }
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

              it { is_expected.to_not contain_package('cups') }

              it { is_expected.to_not contain_package('cups-ipp-utils') }

              it { is_expected.to_not contain_package('cups-ipptool') }
            end
          end
        end

        context "when package_names = ['mycups', 'myipp']" do
          let(:facts) { any_supported_os }

          let(:params) { { package_manage: false, package_names: %w[mycups myipp] } }

          it { is_expected.to_not contain_package('mycups') }

          it { is_expected.to_not contain_package('myipp') }
        end
      end
    end

    describe 'papersize' do
      let(:facts) { any_supported_os }

      context 'when set to undef' do
        it { is_expected.to_not contain_exec('cups::papersize') }
      end

      context 'when set to a4' do
        let(:params) { { papersize: 'a4' } }

        it { is_expected.to contain_exec('cups::papersize').with(command: 'paperconfig -p a4') }

        it { is_expected.to contain_exec('cups::papersize').with(unless: 'cat /etc/papersize | grep -w a4') }
      end
    end

    describe 'purge_unmanaged_queues' do
      let(:facts) { any_supported_os }

      context 'when set to true' do
        let(:params) { { purge_unmanaged_queues: true } }

        it { is_expected.to contain_resources('cups_queue').with(purge: 'true') }
      end

      context 'when set to false' do
        let(:params) { { purge_unmanaged_queues: false } }

        it { is_expected.to contain_resources('cups_queue').with(purge: 'false') }
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

        it { is_expected.to contain_cups_queue('BackOffice').with(ensure: 'printer') }

        it { is_expected.to contain_cups_queue('UpperFloor').with(ensure: 'class', members: ['BackOffice']) }
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

                  it { is_expected.to contain_service('mycups').with(ensure: service_ensure, enable: service_enable) }
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

                  it { is_expected.to contain_service('mycups').with(ensure: service_ensure, enable: service_enable) }

                  it { is_expected.to contain_service('mycups-browsed').with(ensure: service_ensure, enable: service_enable) }
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

            it { is_expected.to_not contain_service(service_names) }
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

            it { is_expected.to_not contain_service('mycups') }
          end
        end
      end
    end

    describe 'page_log_format' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^PageLogFormat/) }
      end

      context "when set to '%p %u %j %T %P %C'" do
        let(:params) { { page_log_format: '%p %u %j %T %P %C' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^PageLogFormat "%p %u %j %T %P %C"$/) }
      end
    end

    describe 'server_alias' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^ServerAlias/) }
      end

      context 'when set to *' do
        let(:params) { { server_alias: '*' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^ServerAlias \*$/) }
      end

      context 'when set to office.initech.com' do
        let(:params) { { server_alias: 'office.initech.com' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^ServerAlias office.initech.com$/) }
      end

      context "when set to ['office.initech.com', 'warehouse.initech.com']" do
        let(:params) { { server_alias: ['office.initech.com', 'warehouse.initech.com'] } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^ServerAlias office.initech.com warehouse.initech.com$/) }
      end
    end

    describe 'server_name' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^ServerName/) }
      end

      context 'when set to office.initech.com' do
        let(:params) { { server_name: 'office.initech.com' } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^ServerName office.initech.com$/) }
      end
    end

    describe 'web_interface' do
      let(:facts) { any_supported_os }

      context 'when not set' do
        let(:params) { {} }

        it { is_expected.to_not contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface/) }
      end

      context 'when set to true' do
        let(:params) { { web_interface: true } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface Yes$/) }
      end

      context 'when set to false' do
        let(:params) { { web_interface: false } }

        it { is_expected.to contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface No$/) }
      end
    end
  end
end
