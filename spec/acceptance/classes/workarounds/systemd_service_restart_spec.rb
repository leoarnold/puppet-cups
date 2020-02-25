# frozen_string_literal: true

require 'spec_helper_acceptance'

def service_and_queue_pp(ensure_workaround)
  <<-MANIFEST
    class { 'cups':
      service_ensure => 'running',
    }
    cups_queue { 'Office':
      ensure => 'printer',
    }
    class { 'cups::workarounds::systemd_service_restart':
      ensure => '#{ensure_workaround}',
    }
  MANIFEST
end

wrong_platform = default_node.platform !~ /\Acentos-7/

RSpec.shared_examples 'a systemd EL7 CUPS without the workaround' do
  let(:manifest) { service_and_queue_pp('absent') }

  it 'fails to connect to CUPS' do
    result = apply_manifest(manifest, expect_failures: true)
    expect(result.stderr).to include('Unable to connect to localhost on port 631')
  end
end

RSpec.describe 'Including class "cups::workarounds::systemd_service_restart"', skip: wrong_platform do
  before(:all) do
    ensure_cups_is_running
    purge_all_queues
  end

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

      # Test before applying the workaround below
      it_behaves_like 'a systemd EL7 CUPS without the workaround'

      context 'with the workaround' do
        let(:manifest) { service_and_queue_pp('present') }

        it 'applies without error' do
          apply_manifest(manifest)
        end

        it 'is idempotent' do
          # Avoid idempotence failures when /etc/systemd/system/cups.socket.d
          # is created as cupsd_unit_file_t and fixed to systemd_unit_file_t on
          # second run. That's a systemd/Puppet/OS/whatever bug, not something
          # we can fix in this module.
          shell('restorecon -Rv /etc/systemd/system/cups.socket.d')

          apply_manifest(manifest, catch_changes: true)
        end
      end

      # Test again to make sure disabling works and we leave a clean system for
      # the rest of the suite.
      it_behaves_like 'a systemd EL7 CUPS without the workaround'
    end
  end
end
