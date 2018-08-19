# frozen_string_literal: true

require 'spec_helper_acceptance'

# See also: https://github.com/leoarnold/puppet-cups/issues/28
RSpec.describe 'Circumventing CUPS issue #4766' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'when ensuring a queue' do
    context 'when is shared via IPP by some remote host' do
      context "when 'shared' is not specified" do
        before(:all) do
          purge_all_queues
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { 'Office':
              ensure  => 'printer',
              uri     => 'ipp://192.168.10.20/printers/Office',
            }
          MANIFEST
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context "when 'shared' is set to true" do
        before(:all) do
          purge_all_queues
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { 'Office':
              ensure  => 'printer',
              uri     => 'ipp://192.168.10.20/printers/Office',
              shared  => true
            }
          MANIFEST
        end

        it 'fails to apply changes' do
          command = apply_manifest(manifest, expect_failures: true)

          expect(command.stderr).to include('printer-is-shared for remote queues')
        end
      end

      context "when 'shared' is set to false" do
        before(:all) do
          purge_all_queues
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { 'Office':
              ensure  => 'printer',
              uri     => 'ipp://192.168.10.20/printers/Office',
              shared  => false
            }
          MANIFEST
        end

        it 'fails to apply changes' do
          command = apply_manifest(manifest, expect_failures: true)

          expect(command.stderr).to include('printer-is-shared for remote queues')
        end
      end
    end
  end
end
