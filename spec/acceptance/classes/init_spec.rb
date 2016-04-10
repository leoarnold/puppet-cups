# encoding: UTF-8
require 'spec_helper_acceptance'

describe 'Including class "cups"' do
  case fact('osfamily')
  when 'Debian', 'Suse'
    packages = ['cups']
    services = ['cups']
  when 'RedHat'
    packages = ['cups', 'cups-ipptool']
    services = ['cups']
  else
    raise('This version of the CUPS module does not know how to install CUPS on your operating system.')
  end

  context 'Default class inclusion' do
    before(:all) do
      manifest = <<-EOS
        package { #{packages}:
          ensure  => purged,
        }
      EOS

      apply_manifest(manifest, catch_failures: true)
    end

    context 'before applying' do
      describe package(packages) do
        it { should_not be_installed }
      end
    end

    context 'when applying' do
      manifest = 'include cups'

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'after applying' do
      packages.each do |name|
        describe package(name) do
          it { should be_installed }
        end
      end

      services.each do |name|
        describe service(name) do
          it { should be_running }
          it { should be_enabled }
        end
      end
    end
  end
end
