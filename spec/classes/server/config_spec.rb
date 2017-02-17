require 'spec_helper'

describe 'cups::server::config' do
  let(:facts) { any_supported_os }

  context 'with default values for all parameters' do
    it { should contain_file('/etc/cups/lpoptions').with(ensure: 'absent') }

    it { should contain_file('/etc/cups/cupsd.conf').with(ensure: 'file', owner: 'root', group: 'lp', mode: '0640') }
  end
end
