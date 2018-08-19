# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  name = 'RSpec&Test_Printer'

  describe 'ensuring a printer' do
    shared_examples 'installing a printer' do |manifest, make_and_model|
      context 'when the queue is absent' do
        before(:all) do
          purge_all_queues
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'installed the specified printer' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include("printer-make-and-model='#{make_and_model}'")
        end
      end

      context 'when the queue is present as a printer' do
        before(:all) do
          purge_all_queues
          add_printers(name)
        end

        it 'does not apply changes' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when the queue is present as a class' do
        before(:all) do
          purge_all_queues
          add_printers_to_classes(name => [])
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'replaced the class with the specified printer' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include("printer-make-and-model='#{make_and_model}'")
        end
      end
    end

    shared_examples 'modifying a printer' do |manifest, make_and_model|
      context 'when the queue is present as a printer' do
        before(:all) do
          purge_all_queues
          add_printers(name)
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'replaced the printer with the specified printer' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include("printer-make-and-model='#{make_and_model}'")
        end
      end
    end

    describe 'as raw queue' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure => 'printer',
        }
      MANIFEST

      include_examples 'installing a printer', [manifest, 'Local Raw Printer']
    end

    describe 'using a model' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure => 'printer',
          model  => 'drv:///sample.drv/deskjet.ppd',
        }
      MANIFEST

      include_examples 'installing a printer', [manifest, 'HP DeskJet Series']
    end

    describe 'using a PPD file' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure => 'printer',
          ppd    => '/tmp/textonly.ppd',
        }
      MANIFEST

      include_examples 'installing a printer', [manifest, 'Generic text-only printer']
    end

    describe 'as raw queue and specifying `make_and_model`' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure         => 'printer',
          make_and_model => 'Local Raw Printer',
        }
      MANIFEST

      include_examples 'modifying a printer', [manifest, 'Local Raw Printer']
    end

    describe 'using a model and specifying `make_and_model`' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure         => 'printer',
          model          => 'drv:///sample.drv/deskjet.ppd',
          make_and_model => 'HP DeskJet Series',
        }
      MANIFEST

      include_examples 'modifying a printer', [manifest, 'HP DeskJet Series']
    end

    describe 'using a PPD file and specifying `make_and_model`' do
      manifest = <<-MANIFEST
        cups_queue { '#{name}':
          ensure         => 'printer',
          ppd            => '/tmp/textonly.ppd',
          make_and_model => 'Generic text-only printer',
        }
      MANIFEST

      include_examples 'modifying a printer', [manifest, 'Generic text-only printer']
    end

    describe 'using a full-fledged manifest' do
      context 'when the queue is absent' do
        before(:all) do
          purge_all_queues
        end

        let(:manifest) do
          <<~MANIFEST
          cups_queue { '#{name}':
            ensure         => 'printer',
            model          => 'drv:///sample.drv/deskjet.ppd',
            make_and_model => 'HP DeskJet Series',
            uri            => 'lpd://192.168.2.105/binary_p1',
            access         => { 'policy' => 'allow', 'users' => ['root'] },
            accepting      => true,
            description    => 'A full-fledged queue',
            enabled        => true,
            held           => true,
            location       => 'Room 101',
            options        => { 'job-quota-period' => '604800', 'job-page-limit' => '100' },
            shared         => false
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
    end
  end

  context 'when managing a printer' do
    context 'when setting the URI' do
      let(:uri) { 'lpd://192.168.2.105/binary_p1' }

      let(:manifest) do
        <<~MANIFEST
          cups_queue { '#{name}':
            ensure => 'printer',
            model  => 'drv:///sample.drv/generic.ppd',
            uri    => '#{uri}',
          }
        MANIFEST
      end

      context 'when the queue is absent' do
        before(:all) do
          purge_all_queues
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'configured the specified URI' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include("device-uri=#{uri}")
        end
      end

      context 'when the queue is present as printer' do
        before(:all) do
          purge_all_queues
          add_printers(name)
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'configured the specified URI' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include("device-uri=#{uri}")
        end
      end
    end
  end
end
