# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.describe 'Including class "cups" with purge_unmanaged_queues' do
  context 'when the Cups service is not running' do
    before(:all) do
      apply_manifest('class { "cups": service_ensure => "stopped" }', catch_failures: true)
    end

    it 'does not produce errors' do
      apply_manifest('class { "cups": purge_unmanaged_queues => true }', catch_failures: true) do
        assert_not_match(/ipptool: Unable to connect to/, stderr)
      end
    end
  end

  context 'when the Cups service is running' do
    before(:all) do
      ensure_cups_is_running
      purge_all_queues
      add_printers('Office')
    end

    let(:manifest) { 'class { "cups": purge_unmanaged_queues => true }' }

    it 'purges unmanaged queues' do
      apply_manifest(manifest, expect_changes: true)
      shell('lpstat -p Office', acceptable_exit_codes: [1])
    end
  end
end
