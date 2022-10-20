# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'when ensuring absence' do
    queue = 'Office'

    let(:manifest) do
      <<~MANIFEST
        cups_queue { '#{queue}':
          ensure => 'absent'
        }
      MANIFEST
    end

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
        add_printers(queue)
      end

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end

      it 'deleted the queue' do # rubocop:disable RSpec/NoExpectationExample
        shell("lpstat -p #{Shellwords.escape(queue)}", acceptable_exit_codes: [1])
      end
    end
  end
end
