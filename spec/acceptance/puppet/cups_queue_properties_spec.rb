require 'spec_helper_acceptance'

describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'managing any queue' do
    before(:all) do
      purge_all_queues
      add_printers(%w(Office))
    end

    context 'changing only the property' do
      context 'accepting' do
        before(:all) do
          shell('cupsreject -E Office')
        end

        context '=> true' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              accepting => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              accepting => 'false'
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

      context 'description' do
        before(:all) do
          shell("lpadmin -E -p Office -D 'color'")
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure       => 'printer',
            model        => 'drv:///sample.drv/generic.ppd',
            uri          => 'lpd://192.168.2.105/binary_p1',
            description  => 'duplex'
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'enabled' do
        before(:all) do
          shell('cupsdisable -E Office')
        end

        context '=> true' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              enabled   => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              enabled   => 'false'
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

      context 'held' do
        before(:all) do
          shell('cupsenable -E --release Office')
        end

        context '=> true' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              held   => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).to match(/printer-state-reasons=\S*hold-new-jobs\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              held   => 'false'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).not_to include(/printer-state-reasons=\S*hold-new-jobs\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      context 'location' do
        before(:all) do
          shell("lpadmin -E -p Office -L 'Room 451'")
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure    => 'printer',
            model     => 'drv:///sample.drv/generic.ppd',
            uri       => 'lpd://192.168.2.105/binary_p1',
            location  => 'Room 101'
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'shared' do
        before(:all) do
          shell('lpadmin -E -p Office -o printer-is-shared=false')
        end

        context '=> true' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              shared    => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              model     => 'drv:///sample.drv/generic.ppd',
              uri       => 'lpd://192.168.2.105/binary_p1',
              shared    => 'false'
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
end
