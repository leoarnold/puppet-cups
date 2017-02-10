require 'spec_helper'

describe 'cups::server' do
  context 'with default values' do
    it { should contain_class('cups::server').with(conf_directory: '/etc/cups') }

    it { should contain_file('/etc/cups').with(ensure: 'directory', owner: 'root', group: 'lp', mode: '0755') }

    it { should contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }

    it { should contain_file('/etc/cups/lpoptions').that_requires('File[/etc/cups]') }

    it { should contain_file('/etc/cups/cupsd.conf').with(ensure: 'file', owner: 'root', group: 'lp', mode: '0640') }

    it { should contain_file('/etc/cups/cupsd.conf').that_requires('File[/etc/cups]') }

    it { should contain_file('/etc/cups/cups-files.conf').with(ensure: 'file', owner: 'root', group: 'lp', mode: '0640') }

    it { should contain_file('/etc/cups/cups-files.conf').that_requires('File[/etc/cups]') }

    it { should contain_file('/etc/cups/ppd').with(ensure: 'directory', owner: 'root', group: 'lp', mode: '0755') }

    it { should contain_file('/etc/cups/ppd').that_requires('File[/etc/cups]') }

    it { should contain_file('/etc/cups/interfaces').with(ensure: 'directory', owner: 'root', group: 'lp', mode: '0755') }

    it { should contain_file('/etc/cups/interfaces').that_requires('File[/etc/cups]') }

    it { should contain_file('/etc/cups/ssl').with(ensure: 'directory', owner: 'root', group: 'lp', mode: '0700') }

    it { should contain_file('/etc/cups/ssl').that_requires('File[/etc/cups]') }

    it do
      should contain_file('/etc/cups/ssl/server.crt')
        .with(ensure: 'link', owner: 'root', group: 'lp', target: '/etc/ssl/certs/ssl-cert-snakeoil.pem')
    end

    it { should contain_file('/etc/cups/ssl/server.crt').that_requires('File[/etc/cups/ssl]') }

    it do
      should contain_file('/etc/cups/ssl/server.key')
        .with(ensure: 'link', owner: 'root', group: 'lp', target: '/etc/ssl/private/ssl-cert-snakeoil.key')
    end

    it { should contain_file('/etc/cups/ssl/server.key').that_requires('File[/etc/cups/ssl]') }
  end

  context 'ensuring absence' do
    let(:params) { { ensure: 'absent' } }

    it { should contain_file('/etc/cups').with(ensure: 'absent', force: 'true') }
  end

  context 'attribute' do
    describe 'ensure' do
      context "=> 'present'" do
        let(:params) { { ensure: 'present' } }

        it { should compile }
      end

      context "=> 'absent'" do
        let(:params) { { ensure: 'absent' } }

        it { should contain_file('/etc/cups').with(ensure: 'absent', force: 'true') }
      end

      context 'with unsupported value' do
        let(:params) { { ensure: 'some_string' } }

        it { should_not compile }
      end
    end

    describe 'conf_directory' do
      context "=> '/usr/local/etc/cups'" do
        let(:params) { { conf_directory: '/usr/local/etc/cups' } }

        it { should contain_file('/usr/local/etc/cups') }

        it { should contain_file('/usr/local/etc/cups/lpoptions') }

        it { should contain_file('/usr/local/etc/cups/lpoptions').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/cupsd.conf') }

        it { should contain_file('/usr/local/etc/cups/cupsd.conf').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/cups-files.conf') }

        it { should contain_file('/usr/local/etc/cups/cups-files.conf').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/interfaces') }

        it { should contain_file('/usr/local/etc/cups/interfaces').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/ppd') }

        it { should contain_file('/usr/local/etc/cups/ppd').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/ssl') }

        it { should contain_file('/usr/local/etc/cups/ssl').that_requires('File[/usr/local/etc/cups]') }

        it { should contain_file('/usr/local/etc/cups/ssl/server.crt') }

        it { should contain_file('/usr/local/etc/cups/ssl/server.crt').that_requires('File[/usr/local/etc/cups/ssl]') }

        it { should contain_file('/usr/local/etc/cups/ssl/server.key') }

        it { should contain_file('/usr/local/etc/cups/ssl/server.key').that_requires('File[/usr/local/etc/cups/ssl]') }
      end

      context 'with unsupported value' do
        let(:params) { { conf_directory: 'some_string' } }

        it { should_not compile }

        it { expect { should contain_file('some_string') }.to raise_error(/absolute path/) }
      end
    end

    describe 'file_device' do
      context 'by default' do
        it { should_not contain_file('/etc/cups/cups-files.conf').with(content: /^FileDevice/) }
      end

      context '=> true' do
        let(:params) { { file_device: true } }

        it { should contain_file('/etc/cups/cups-files.conf').with(content: /^FileDevice Yes$/) }
      end

      context '=> false' do
        let(:params) { { file_device: false } }

        it { should contain_file('/etc/cups/cups-files.conf').with(content: /^FileDevice No$/) }
      end

      context 'with unsupported value' do
        let(:params) { { file_device: 'some_string' } }

        it { should_not compile }
      end
    end

    describe 'listen' do
      context 'by default' do
        it { should_not contain_file('/etc/cups/cupsd.conf').with(content: /^Listen/) }
      end

      context "=> 'localhost:631'" do
        let(:params) { { listen: 'localhost:631' } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:631$/) }
      end

      context "=> ['localhost:631', '/var/run/cups/cups.sock']" do
        let(:params) { { listen: ['localhost:631', '/var/run/cups/cups.sock'] } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Listen localhost:631$/) }
        it { should contain_file('/etc/cups/cupsd.conf').with(content: %r{^Listen /var/run/cups/cups.sock$}) }
      end
    end

    describe 'log_level' do
      context 'by default' do
        it { should_not contain_file('/etc/cups/cupsd.conf').with(content: /^LogLevel/) }
      end

      context '=> warn' do
        let(:params) { { log_level: 'warn' } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^LogLevel warn$/) }
      end

      context 'with unsupported value' do
        let(:params) { { log_level: 'some_string' } }

        it { should_not compile }
      end
    end

    describe 'port' do
      context 'by default' do
        it { should_not contain_file('/etc/cups/cupsd.conf').with(content: /^Port/) }
      end

      context '=> 631' do
        let(:params) { { port: 631 } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Port 631$/) }
      end

      context '=> [631, 8080]' do
        let(:params) { { port: [631, 8080] } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Port 631$/) }
        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^Port 8080$/) }
      end

      context 'with unsupported value' do
        let(:params) { { port: [631, 'some_string'] } }

        it { should_not compile }
      end
    end

    describe 'web_interface' do
      context 'by default' do
        it { should_not contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface/) }
      end

      context '=> true' do
        let(:params) { { web_interface: true } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface Yes$/) }
      end

      context '=> false' do
        let(:params) { { web_interface: false } }

        it { should contain_file('/etc/cups/cupsd.conf').with(content: /^WebInterface No$/) }
      end

      context 'with unsupported value' do
        let(:params) { { web_interface: 'some_string' } }

        it { should_not compile }
      end
    end
  end
end
