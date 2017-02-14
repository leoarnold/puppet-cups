require 'spec_helper_acceptance'

describe 'Including class "cups"' do
  before(:all) do
    ensure_cups_is_running
  end

  name = 'RSpec&Test_Printer'

  context 'and specifying a `default_queue`' do
    context 'when the catalog does NOT contain a `cups_queue` resource with the same name' do
      before(:all) do
        purge_all_queues
      end

      manifest = <<-EOM
        class { '::cups':
          default_queue => '#{name}'
        }
      EOM

      it 'fails to apply' do
        apply_manifest(manifest, expect_failures: true)
      end
    end

    context 'when the catalog contains a `cups_queue` resource with the same name' do
      before(:all) do
        add_printers('BackOffice')
        shell('lpadmin -d BackOffice')
      end

      manifest = <<-EOM
        class { '::cups':
          default_queue => '#{name}'
        }

        cups_queue { '#{name}':
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd',
          uri    => 'lpd://192.168.2.105/binary_p1'
        }
      EOM

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'sets the correct value' do
        expect(shell('lpstat -d').stdout.split(/\s/)).to include(name)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end
  end
end
