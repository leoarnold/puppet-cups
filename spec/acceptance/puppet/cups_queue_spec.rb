require 'spec_helper_acceptance'

describe 'Custom type `cups_queue`' do
  context 'managing a printer' do
    context 'ensuring absence' do
      context 'when the printer is absent' do
        before(:all) do
          purge_all_queues
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure => 'absent'
          }
        EOM

        it 'does not apply changes' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when the printer is present' do
        before(:all) do
          purge_all_queues
          add_printers(%w(Office))
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure => 'absent'
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

    context 'ensuring presence' do
      context 'when the printer is absent' do
        context 'specifying only mandatory attributes' do
          before(:all) do
            purge_all_queues
          end

          manifest = <<-EOM
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

      context 'when the printer is present' do
        context 'changing the uri' do
          before(:all) do
            purge_all_queues
            add_printers(%w(Office))
            shell('lpadmin -p Office -v lpd://192.168.2.105/binary_p1')
          end

          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              model  => 'drv:///sample.drv/generic.ppd',
              uri    => 'socket://10.0.0.5:9100'
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
    end
  end

  context 'managing a class' do
    context 'ensuring absence' do
      context 'when the class is absent' do
        before(:all) do
          purge_all_queues
        end

        manifest = <<-EOM
          cups_queue { 'GroundFloor':
            ensure => 'absent'
          }
        EOM

        it 'does not apply changes' do
          apply_manifest(manifest, catch_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when the class is present' do
        before(:all) do
          add_printers(%w(Office Warehouse))
          add_printers_to_classes('GroundFloor' => %w(Office Warehouse))
        end

        manifest = <<-EOM
          cups_queue { 'GroundFloor':
            ensure => 'absent'
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

    context 'ensuring presence' do
      context 'when the class is absent' do
        context 'and all designated members are present' do
          before(:all) do
            purge_all_queues
            add_printers(%w(Office Warehouse))
          end

          manifest = <<-EOM
            cups_queue { 'GroundFloor':
              ensure  => 'class',
              members => ['Office', 'Warehouse']
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'and all designated members are absent' do
          context 'and NOT specified in the catalog' do
            before(:all) do
              purge_all_queues
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }
            EOM

            it 'applying the manifest fails' do
              apply_manifest(manifest, expect_failure: true)
            end
          end

          context 'but specified in the catalog' do
            before(:all) do
              purge_all_queues
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }

              cups_queue { 'Office':
                ensure => 'printer',
                model  => 'drv:///sample.drv/generic.ppd',
                uri    => 'lpd://192.168.2.105/binary_p1'
              }

              cups_queue { 'Warehouse':
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
      end

      context 'when the class is present' do
        context 'and all designated members are present' do
          context 'but some are not members yet' do
            before(:all) do
              purge_all_queues
              add_printers(%w(Office Warehouse))
              add_printers_to_classes('GroundFloor' => %w(Warehouse))
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }
            EOM

            it 'applies changes' do
              apply_manifest(manifest, expect_changes: true)
            end

            it 'is idempotent' do
              apply_manifest(manifest, catch_changes: true)
            end
          end

          context 'and the class already consists of them in wrong order' do
            before(:all) do
              purge_all_queues
              add_printers(%w(Office Warehouse))
              add_printers_to_classes('GroundFloor' => %w(Warehouse Office))
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }
            EOM

            it 'enforces the given order' do
              apply_manifest(manifest, expect_changes: true)
            end

            it 'is idempotent' do
              apply_manifest(manifest, catch_changes: true)
            end
          end

          context 'and they already are members amongst others' do
            before(:all) do
              purge_all_queues
              add_printers(%w(BackOffice Office Warehouse))
              add_printers_to_classes('GroundFloor' => %w(Warehouse BackOffice Office))
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }
            EOM

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
          context 'and there are NO unwanted members' do
            before(:all) do
              purge_all_queues
              add_printers(%w(Office))
              add_printers_to_classes('GroundFloor' => %w(Office))
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }

              cups_queue { 'Office':
                ensure => 'printer',
                model  => 'drv:///sample.drv/generic.ppd',
                uri    => 'lpd://192.168.2.105/binary_p1'
              }

              cups_queue { 'Warehouse':
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

          context 'and there are unwanted members' do
            before(:all) do
              purge_all_queues
              add_printers(%w(BackOffice Office))
              add_printers_to_classes('GroundFloor' => %w(BackOffice Office))
            end

            manifest = <<-EOM
              cups_queue { 'GroundFloor':
                ensure  => 'class',
                members => ['Office', 'Warehouse']
              }

              cups_queue { 'Office':
                ensure => 'printer',
                model  => 'drv:///sample.drv/generic.ppd',
                uri    => 'lpd://192.168.2.105/binary_p1'
              }

              cups_queue { 'Warehouse':
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

            it 'did not delete the queues of former members' do
              expect(shell('lpstat -p BackOffice').exit_code).to eq(0)
            end
          end
        end
      end
    end
  end

  context 'converting' do
    context 'a class to a printer' do
      before(:all) do
        purge_all_queues
        add_printers(%w(Office))
        add_printers_to_classes('GroundFloor' => %w(Office))
      end

      manifest = <<-EOM
        cups_queue { 'GroundFloor':
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

    context 'a printer to a class' do
      before(:all) do
        purge_all_queues
        add_printers(%w(GroundFloor Office Warehouse))
      end

      manifest = <<-EOM
        cups_queue { 'GroundFloor':
          ensure  => 'class',
          members => ['Office', 'Warehouse']
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

  context 'managing any queue' do
    before(:all) do
      purge_all_queues
      add_printer(%w(Office))
    end

    context 'changing only the property' do
    end
  end
end
