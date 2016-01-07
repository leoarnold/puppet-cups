require 'spec_helper_acceptance'

describe 'Including class "cups"' do
  package_name = 'cups'
  service_name = 'cups'

  context 'Default class inclusion' do
    before(:all) do
      manifest = <<-EOS
        package { "#{package_name}":
          ensure  => purged,
        }
      EOS

      apply_manifest(manifest, catch_failures: true)
    end

    context 'before applying' do
      describe package(package_name) do
        it { should_not be_installed }
      end
    end

    context 'when applying' do
      manifest = 'include cups'

      it 'applies changes' do
        apply_manifest(manifest, expect_changes: true)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'after applying' do
      describe package(package_name) do
        it { should be_installed }
      end

      describe service(service_name) do
        it { should be_running }
        it { should be_enabled }
      end
    end
  end
end
