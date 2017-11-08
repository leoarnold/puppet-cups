# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'ensuring a class' do
    context 'when the queue is absent' do
      context 'and all designated members are present' do
        context 'using a minimal manifest' do
          before(:all) do
            purge_all_queues
            add_printers('Office', 'Warehouse')
          end

          manifest = <<-MANIFEST
            cups_queue { 'GroundFloor':
              ensure  => 'class',
              members => ['Office', 'Warehouse']
            }
          MANIFEST

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'using a full-fledged manifest' do
          before(:all) do
            purge_all_queues
            add_printers('Office', 'Warehouse')
          end

          manifest = <<-MANIFEST
            cups_queue { 'GroundFloor':
              ensure         => 'class',
              members        => ['Office', 'Warehouse'],
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

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      context 'and all designated members are absent' do
        context 'and NOT specified in the catalog' do
          before(:all) do
            purge_all_queues
          end

          manifest = <<-MANIFEST
            cups_queue { 'GroundFloor':
              ensure  => 'class',
              members => ['Office', 'Warehouse']
            }
          MANIFEST

          it 'applying the manifest fails' do
            apply_manifest(manifest, expect_failures: true)
          end
        end

        context 'but specified in the catalog' do
          before(:all) do
            purge_all_queues
          end

          manifest = <<-MANIFEST
            cups_queue { 'GroundFloor':
              ensure  => 'class',
              members => ['Office', 'Warehouse']
            }

            cups_queue { ['Office', 'Warehouse']:
              ensure => 'printer',
              model  => 'drv:///sample.drv/generic.ppd',
            }
          MANIFEST

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end
    end

    context 'when the queue is present as class' do
      context 'and all designated members are present' do
        manifest = <<-MANIFEST
          cups_queue { 'GroundFloor':
            ensure  => 'class',
            members => ['Office', 'Warehouse']
          }
        MANIFEST

        context 'but some are not members yet' do
          before(:all) do
            purge_all_queues
            add_printers('Office', 'Warehouse')
            add_printers_to_classes('GroundFloor' => %w[Warehouse])
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'and the class already consists of them, but in wrong order' do
          before(:all) do
            purge_all_queues
            add_printers('Office', 'Warehouse')
            add_printers_to_classes('GroundFloor' => %w[Warehouse Office])
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'and they already are members, amongst others' do
          before(:all) do
            purge_all_queues
            add_printers('BackOffice', 'Office', 'Warehouse')
            add_printers_to_classes('GroundFloor' => %w[Warehouse BackOffice Office])
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end

          it 'did not delete the queues of former members' do
            expect(shell('lpstat -p BackOffice').exit_code).to eq(0)
          end
        end
      end

      context 'and some of the designated members are absent' do
        manifest = <<-MANIFEST
          cups_queue { 'GroundFloor':
            ensure  => 'class',
            members => ['Office', 'Warehouse']
          }

          cups_queue { ['Office', 'Warehouse']:
            ensure => 'printer',
            model  => 'drv:///sample.drv/generic.ppd',
          }
        MANIFEST

        context 'and there are NO unwanted members' do
          before(:all) do
            purge_all_queues
            add_printers('Office')
            add_printers_to_classes('GroundFloor' => %w[Office])
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'and there are unwanted members' do
          before(:all) do
            purge_all_queues
            add_printers('BackOffice', 'Office')
            add_printers_to_classes('GroundFloor' => %w[BackOffice Office])
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end

          it 'did not delete the queues of former members' do
            expect(shell('lpstat -p BackOffice').exit_code).to eq(0)
          end
        end
      end
    end

    context 'when the queue is present as printer' do
      before(:all) do
        purge_all_queues
        add_printers('GroundFloor', 'Office', 'Warehouse')
      end

      manifest = <<-MANIFEST
        cups_queue { 'GroundFloor':
          ensure  => 'class',
          members => ['Office', 'Warehouse']
        }
      MANIFEST

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end
  end
end
