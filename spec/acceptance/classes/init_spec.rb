# encoding: UTF-8
require 'spec_helper_acceptance'

describe 'Including class "cups"' do
  context 'Default class inclusion' do
    context 'when applying' do
      manifest = 'include cups'

      it 'applies without error' do
        apply_manifest(manifest)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'after applying' do
      describe service('cups') do
        it { should be_running }
        it { should be_enabled }
      end

      describe file('/usr/bin/ipptool') do
        it { should be_executable }
      end
    end
  end

  context 'with attribute' do
    describe 'filedevice' do
      context '= true' do
        before(:all) do
          purge_all_queues
          shell("sed -i '/FileDevice/s/Yes/No/g' /etc/cups/cups-files.conf")
        end

        class_manifest = <<-EOM
          class { '::cups':
            filedevice => true,
          }
        EOM

        printer_manifest = <<-EOM
          cups_queue { 'Office':
            ensure => 'printer',
            uri    => 'file:///printout'
          }
        EOM

        it 'applies changes' do
          apply_manifest(class_manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(class_manifest, catch_changes: true)
        end

        it 'enabled file URIs' do
          apply_manifest(printer_manifest, expect_changes: true)
        end
      end

      context '= false' do
        before(:all) do
          purge_all_queues
          shell("sed -i '/FileDevice/s/No/Yes/g' /etc/cups/cups-files.conf")
        end

        class_manifest = <<-EOM
          class { '::cups':
            filedevice => false,
          }
        EOM

        printer_manifest = <<-EOM
          cups_queue { 'Office':
            ensure => 'printer',
            uri    => 'file:///printout'
          }
        EOM

        it 'applies changes' do
          apply_manifest(class_manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(class_manifest, catch_changes: true)
        end

        it 'disabled file URIs' do
          apply_manifest(printer_manifest, expect_failures: true)
        end
      end
    end
  end
end
