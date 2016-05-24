# encoding: UTF-8
require 'spec_helper_acceptance'

describe 'Including class "cups"' do
  context 'Default class inclusion' do
    context 'when applying' do
      manifest = 'include cups'

      it 'applies without error' do
        apply_manifest(manifest)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'after applying' do
      describe service('cups') do
        it { should be_running }
        it { should be_enabled }
      end

      describe file('/usr/bin/ipptool') do
        it { should be_executable }
      end
    end
  end
end
