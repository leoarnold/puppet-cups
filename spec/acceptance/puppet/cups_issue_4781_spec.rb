# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Circumventing CUPS issue #4781' do
  let(:manifest) do
    <<~MANIFEST
      cups_queue { 'Office':
        ensure  => 'printer',
        access  => #{access},
        enabled => true
      }
    MANIFEST
  end

  before(:all) do
    ensure_cups_is_running
  end

  context 'when ensuring a queue' do
    context 'when the queue is absent' do
      context 'without specifying an ACL' do
        before(:all) do
          purge_all_queues
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { 'Office':
              ensure  => 'printer',
              enabled => true,
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

      context 'when admitting everybody' do
        before(:all) do
          purge_all_queues
        end

        let(:access) { "{ 'policy' => 'allow', users => ['all'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when admitting just one specific user' do
        before(:all) do
          purge_all_queues
        end

        let(:access) { "{ 'policy' => 'allow', users => ['sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying just one specific user' do
        before(:all) do
          purge_all_queues
        end

        let(:access) { "{ 'policy' => 'deny', users => ['sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying several users' do
        before(:all) do
          purge_all_queues
        end

        let(:access) { "{ 'policy' => 'deny', users => ['root', 'sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying everybody' do
        before(:all) do
          purge_all_queues
        end

        let(:access) { "{ 'policy' => 'deny', users => ['all'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end
    end

    context "when the queue is present, disabled and restricted to user 'sshd'" do
      context 'without specifying an ACL' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:manifest) do
          <<~MANIFEST
            cups_queue { 'Office':
              ensure  => 'printer',
              enabled => true,
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

      context 'when admitting everybody' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'allow', users => ['all'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when admitting just one specific user' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'allow', users => ['sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when admitting several users' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'allow', users => ['root', 'sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying just one specific user' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'deny', users => ['sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying several users' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'deny', users => ['root', 'sshd'] }" }

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'when denying everybody' do
        before(:all) do
          shell('lpadmin -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable Office')
        end

        let(:access) { "{ 'policy' => 'deny', users => ['all'] }" }

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
