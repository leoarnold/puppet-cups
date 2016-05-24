# encoding: UTF-8
require 'spec_helper_acceptance'

describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'ensuring absence' do
    queue = 'Office'

    manifest = <<-EOM
      cups_queue { '#{queue}':
        ensure => 'absent'
      }
    EOM

    context 'when the queue is absent' do
      before(:all) do
        purge_all_queues
      end

      it 'does not apply changes' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'when the queue is present' do
      before(:all) do
        purge_all_queues
        add_printers([queue])
      end

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end

      it 'deleted the queue' do
        shell("lpstat -p #{queue}", acceptable_exit_codes: [1])
      end
    end
  end
end
