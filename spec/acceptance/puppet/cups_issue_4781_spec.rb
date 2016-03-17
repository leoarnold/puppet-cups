# encoding: UTF-8
require 'spec_helper_acceptance'

def manifest(access)
  "cups_queue { 'Office':
    ensure  => 'printer',
    access  => #{access},
    enabled => 'true',
  }"
end

describe 'Circumventing CUPS issue #4781' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'ensuring a queue' do
    context 'when the queue is absent' do
      context 'without specifying an ACL' do
        before(:all) do
          purge_all_queues
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure  => 'printer',
            enabled => 'true',
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'with access =' do
        describe "{ 'policy' => 'allow', users => ['all'] }" do
          before(:all) do
            purge_all_queues
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'allow', users => ['sshd'] }" do
          before(:all) do
            purge_all_queues
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), catch_failure: true, expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['sshd'] }" do
          before(:all) do
            purge_all_queues
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['root', 'sshd'] }" do
          before(:all) do
            purge_all_queues
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['all'] }" do
          before(:all) do
            purge_all_queues
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end
      end
    end

    context "when the queue is present, disabled and restricted to user 'sshd'" do
      context 'without specifying an ACL' do
        before(:all) do
          shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
          shell('cupsdisable -E Office')
        end

        manifest = <<-EOM
          cups_queue { 'Office':
            ensure  => 'printer',
            enabled => 'true',
          }
        EOM

        it 'applies changes' do
          apply_manifest(manifest, expect_changes: true)
        end

        it 'is idempotent' do
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'with access =' do
        describe "{ 'policy' => 'allow', users => ['all'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'allow', users => ['sshd'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'allow', users => ['root', 'sshd'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['sshd'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['root', 'sshd'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end

        describe "{ 'policy' => 'deny', users => ['all'] }" do
          before(:all) do
            shell('lpadmin -E -p Office -v /dev/null -u allow:sshd')
            shell('cupsdisable -E Office')
          end

          it 'applies changes' do
            apply_manifest(manifest(subject), expect_changes: true)
          end

          it 'is idempotent' do
            apply_manifest(manifest(subject), catch_changes: true)
          end
        end
      end
    end
  end
end
