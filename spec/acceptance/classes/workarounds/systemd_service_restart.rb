# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Including class "cups::workarounds::systemd_service_restart"' do
  before(:all) do
    ensure_cups_is_running
    purge_all_queues
  end

  let(:manifest) { "include '::cups::workarounds::systemd_service_restart'" }

  describe 'restarting the CUPS server' do
    before(:all) do
      # Trigger a restart of the Class[cups::server::service] through Class[cups::server::config]
      shell('touch /etc/cups/lpoptions')
    end

    context 'when there are a lot of queues present' do
      before(:all) do
        names = (1..100).map { |n| "Queue#{n.to_s.rjust(3, '0')}" }

        # Increase RAM on virtual machine if this command runs suspiciously slow
        add_printers(*names)
      end

      it 'applies without error' do
        apply_manifest(manifest)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end
  end
end
