# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Custom type `cups_queue`' do
  before(:all) do
    ensure_cups_is_running
  end

  name = 'RSpec&Test_Printer'

  context 'when managing any queue' do
    before(:all) do
      purge_all_queues
      add_printers(name)
    end

    context 'when changing only the property' do
      describe 'access' do
        before(:all) do
          shell("lpadmin -E -p #{Shellwords.escape(name)} -u allow:all")
        end

        context 'with policy => allow' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['nina', 'lumbergh', '@council', 'nina'],
              }
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

        context 'with policy => allow and changing users' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['lumbergh', 'bolton'],
              }
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

        context 'with policy => deny' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              access => {
                'policy' => 'deny',
                'users'  => ['nina', 'lumbergh', '@council', 'nina'],
              }
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

        context 'with policy => deny and changing users' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              access => {
                'policy' => 'deny',
                'users'  => ['lumbergh', 'bolton'],
              }
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

        context 'when unsetting all restrictions' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              access => {
                'policy' => 'allow',
                'users'  => ['all'],
              }
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

      describe 'accepting' do
        before(:all) do
          shell("cupsreject -E #{Shellwords.escape(name)}")
        end

        context 'when set to true' do
          let(:manifest) do
            <<~MANIFEST
              cups_queue { '#{name}':
                ensure    => 'printer',
                accepting => true
              }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include('printer-is-accepting-jobs=true')
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'when set to false' do
          let(:manifest) do
            <<~MANIFEST
              cups_queue { '#{name}':
                ensure    => 'printer',
                accepting => false
              }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include('printer-is-accepting-jobs=false')
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      describe 'description' do
        before(:all) do
          shell("lpadmin -E -p #{Shellwords.escape(name)} -D 'color'")
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { '#{name}':
              ensure      => 'printer',
              description => 'duplex'
            }
          MANIFEST
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'sets the correct value' do
          expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to include('printer-info=duplex')
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      describe 'enabled' do
        before(:all) do
          shell("cupsdisable -E #{Shellwords.escape(name)}")
        end

        context 'when set to true' do
          let(:manifest) do
            <<~MANIFEST
              cups_queue { '#{name}':
                ensure  => 'printer',
                enabled => true
              }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to_not match(/printer-state-reasons=\S*paused\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'when set to false' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure  => 'printer',
              enabled => false
            }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to match(/printer-state-reasons=\S*paused\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      describe 'held' do
        before(:all) do
          shell("cupsenable -E --release #{Shellwords.escape(name)}")
        end

        context 'when set to true' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              held   => true
            }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to match(/printer-state-reasons=\S*hold-new-jobs\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end

        context 'when set to false' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              held   => false
            }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct value' do
            expect(shell("lpoptions -p #{Shellwords.escape(name)}").stdout).to_not match(/printer-state-reasons=\S*hold-new-jobs\S*/)
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      describe 'location' do
        before(:all) do
          shell("lpadmin -E -p #{Shellwords.escape(name)} -L 'Room 451'")
        end

        let(:manifest) do
          <<~MANIFEST
          cups_queue { '#{name}':
            ensure   => 'printer',
            location => 'Room 101'
          }
          MANIFEST
        end

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'sets the correct value' do
          expect(shell("lpstat -l -p #{Shellwords.escape(name)}").stdout).to include('Room 101')
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      describe 'options' do
        context 'when using native options' do
          before(:all) do
            shell("lpadmin -E -p #{Shellwords.escape(name)}" \
              ' -o auth-info-required=negotiate' \
              ' -o job-sheets-default=banner,banner' \
              ' -o printer-error-policy=retry-current-job')
          end

          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure  => 'printer',
              options => {
                'auth-info-required'   => 'username,password',
                'printer-error-policy' => 'stop-printer',
                'job-sheets-default'   => 'none,none'
              }
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

        context 'when using vendor options' do
          before(:all) do
            shell("lpadmin -E -p #{Shellwords.escape(name)} -o Duplex=None")
          end

          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure  => 'printer',
              options => {
                'Duplex'   => 'DuplexNoTumble',
              }
            }
            MANIFEST
          end

          it 'applies changes' do
            apply_manifest(manifest, expect_changes: true)
          end

          it 'sets the correct values' do
            output = shell("lpoptions -p #{Shellwords.escape(name)} -l").stdout

            expect(output).to match(%r{Duplex/.*\s\*DuplexNoTumble\s})
          end

          it 'is idempotent' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      describe 'shared' do
        before(:all) do
          shell("lpadmin -E -p #{Shellwords.escape(name)} -o printer-is-shared=false")
        end

        context 'when set to true' do
          let(:manifest) do
            <<~MANIFEST
            cups_queue { '#{name}':
              ensure => 'printer',
              shared => true
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

        context 'when set to false' do
          let(:manifest) do
            <<~MANIFEST
              cups_queue { '#{name}':
                ensure => 'printer',
                shared => false
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
  end
end
