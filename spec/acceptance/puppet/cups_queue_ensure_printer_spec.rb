require 'spec_helper_acceptance'

describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  name = 'Office'

  context 'ensuring a printer' do
    context 'using a model' do
      manifest = <<-EOM
        cups_queue { #{name}:
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd',
        }
      EOM

      make_and_model = 'Generic PostScript Printer'

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

        it 'installed the specified model' do
          expect(shell("lpoptions -p #{name}").stdout).to include("printer-make-and-model='#{make_and_model}'")
        end
      end

      context 'when the queue is present as a printer' do
        before(:all) do
          purge_all_queues
          add_printers([name])
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
          expect(shell("lpoptions -p #{name}").stdout).to include("printer-make-and-model='#{make_and_model}'")
        end
      end
    end
  end

  context 'managing a printer' do
    context 'setting the URI' do
      uri = 'lpd://192.168.2.105/binary_p1'

      manifest = <<-EOM
        cups_queue { #{name}:
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd',
          uri    => '#{uri}',
        }
      EOM

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
          expect(shell("lpoptions -p #{name}").stdout).to include("device-uri=#{uri}")
        end
      end

      context 'when the queue is present as printer' do
        before(:all) do
          purge_all_queues
          add_printers([name])
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'configured the specified URI' do
          expect(shell("lpoptions -p #{name}").stdout).to include("device-uri=#{uri}")
        end
      end
    end
  end
end
