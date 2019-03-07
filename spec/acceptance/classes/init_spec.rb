# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Including class "cups"' do
  describe 'default class inclusion' do
    context 'when applying' do
      let(:manifest) { "include '::cups'" }

      it 'applies without error' do
        apply_manifest(manifest)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    describe 'after applying' do
      describe service('cups') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end

      describe file('/usr/bin/ipptool') do
        it { is_expected.to be_executable }
      end
    end
  end

  context 'when setting parameter' do
    describe 'papersize' do
      let(:manifest) do
        <<~MANIFEST
          class { '::cups':
            papersize => 'a4'
          }
        MANIFEST
      end

      it 'applies without error' do
        apply_manifest(manifest)
      end

      it 'is idempotent' do
        apply_manifest(manifest, catch_changes: true)
      end
    end
  end
end
