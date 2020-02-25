# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'cups::workarounds::systemd_service_restart' do
  let(:dropin_name) { 'wait_until_cups_listens_on_port_631.conf' }

  let(:dropin_content) { /^\[Socket\]\nListenStream=\[::1\]:631$/ }

  context 'when the distribution is NOT based on systemd' do
    let(:facts) { any_supported_os(systemd: false) }

    it { is_expected.to_not contain_systemd__dropin_file(dropin_name) }
  end

  context 'when the distribution is systemd based' do
    let(:facts) { any_supported_os(systemd: true) }

    it { is_expected.to contain_systemd__dropin_file(dropin_name).that_notifies('Class[cups::server::services]') }

    context 'without params' do
      it { is_expected.to contain_systemd__dropin_file(dropin_name).with(ensure: 'present', unit: 'cups.socket', content: dropin_content) }
    end

    context "with unit = 'mycups.socket'" do
      let(:params) { { unit: 'mycups.socket' } }

      it { is_expected.to contain_systemd__dropin_file(dropin_name).with(ensure: 'present', unit: 'mycups.socket', content: dropin_content) }
    end

    context 'with ensure = absent' do
      let(:params) { { ensure: 'absent' } }

      it { is_expected.to contain_systemd__dropin_file(dropin_name).with(ensure: 'absent') }
    end
  end
end
