require 'spec_helper_acceptance'

describe 'Including class "::cups::default_queue"' do
  context 'without specifying a `cups_queue` resource for the desired queue' do
    before(:all) do
      purge_all_queues
    end

    manifest = <<-EOM
      class { '::cups::default_queue':
        queue => 'Office'
      }
    EOM

    it 'fails to apply' do
      apply_manifest(manifest, acceptable_exit_codes: 1, expect_failure: true)
    end
  end

  context 'and specifying a `cups_queue` resource for the desired queue' do
    before(:all) do
      purge_all_queues
    end

    manifest = <<-EOM
      class { '::cups::default_queue':
        queue => 'Office'
      }

      cups_queue { 'Office':
        ensure => 'printer',
        model  => 'drv:///sample.drv/generic.ppd',
        uri    => 'lpd://192.168.2.105/binary_p1'
      }
    EOM

    it 'applies changes' do
      apply_manifest(manifest, expect_changes: true)
    end

    it 'is idempotent' do
      apply_manifest(manifest, catch_changes: true)
    end
  end
end
