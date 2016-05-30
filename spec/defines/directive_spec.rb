# encoding: UTF-8
require 'spec_helper'

describe 'cups::directive' do
  let(:title) { 'Directive' }

  context "without attribute 'ensure'" do
    let(:params) { { file: 'cups-files.conf' } }

    it { should raise_error(/ensure/) }
  end

  context "without attribute 'file'" do
    let(:params) { { ensure: 'Value' } }

    it { should raise_error(/file/) }
  end

  context "with ensure => 'Value' and file => 'cups-files.conf'" do
    let(:params) { { ensure: 'Value', file: 'cups-files.conf' } }

    it { should contain_augeas('cups-files.conf/Directive Value').with(context: '/files/etc/cups/cups-files.conf') }

    it do
      should contain_augeas('cups-files.conf/Directive Value')
        .with(changes: ['set directive[ . = "Directive" ] "Directive"', 'set directive[ . = "Directive" ]/arg "Value"'])
    end
  end

  context "with ensure => 'Value', confdir => '/usr/local/etc/cups/' and file => 'cups-files.conf'" do
    let(:params) { { ensure: 'Value', confdir: '/usr/local/etc/cups', file: 'cups-files.conf' } }

    it { should contain_augeas('cups-files.conf/Directive Value').with(context: '/files/usr/local/etc/cups/cups-files.conf') }

    it do
      should contain_augeas('cups-files.conf/Directive Value')
        .with(changes: ['set directive[ . = "Directive" ] "Directive"', 'set directive[ . = "Directive" ]/arg "Value"'])
    end
  end
end
