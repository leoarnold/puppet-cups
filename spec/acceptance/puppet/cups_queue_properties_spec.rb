# encoding: UTF-8
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
      context 'access' do
        before(:all) do
          shell('lpadmin -E -p Office -u allow:all')
        end

        context 'with policy => allow' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['nina', 'lumbergh', '@council', 'nina'],
              }
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'with policy => allow and changing users' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['lumbergh', 'bolton'],
              }
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'with policy => deny' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              access => {
                'policy' => 'deny',
                'users'  => ['nina', 'lumbergh', '@council', 'nina'],
              }
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'with policy => deny and changing users' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              access => {
                'policy' => 'deny',
                'users'  => ['lumbergh', 'bolton'],
              }
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'unsetting all restrictions' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['all'],
              }
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

      context 'accepting' do
        before(:all) do
          shell('cupsreject -E Office')
        end

        context '=> true' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              accepting => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).to include('printer-is-accepting-jobs=true')
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure    => 'printer',
              accepting => 'false'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).to include('printer-is-accepting-jobs=false')
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
            ensure      => 'printer',
            description => 'duplex'
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'sets the correct value' do
          expect(shell('lpoptions -p Office').stdout).to include('printer-info=duplex')
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
              ensure  => 'printer',
              enabled => 'true'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).not_to match(/printer-state-reasons=\S*paused\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context '=> false' do
          manifest = <<-EOM
            cups_queue { 'Office':
              ensure  => 'printer',
              enabled => 'false'
            }
          EOM

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell('lpoptions -p Office').stdout).to match(/printer-state-reasons=\S*paused\S*/)
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
            expect(shell('lpoptions -p Office').stdout).not_to match(/printer-state-reasons=\S*hold-new-jobs\S*/)
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
            ensure   => 'printer',
            location => 'Room 101'
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'sets the correct value' do
          expect(shell('lpstat -l -p Office').stdout).to include('Room 101')
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'options' do
        before(:all) do
          shell('lpadmin -E -p Office -o Duplex=None -o PageSize=Letter')
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure  => 'printer',
            options => {
              'Duplex'   => 'DuplexNoTumble',
              'PageSize' => 'A4'
            }
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'sets the correct value' do
          output = shell('lpoptions -p Office -l').stdout
          expect(output).to match(%r{Duplex/.*\s\*DuplexNoTumble\s})
          expect(output).to match(%r{PageSize/.*\s\*A4\s})
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
              ensure => 'printer',
              shared => 'true'
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
              ensure => 'printer',
              shared => 'false'
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
