require 'spec_helper'

describe 'nina.initech.com' do
  let(:facts) { any_supported_os(certname: 'nina.initech.com') }

  let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

  context 'using a hiera example' do
    it { should contain_node('nina.initech.com') }

    it { should contain_class('cups').with(web_interface: true) }

    it { should contain_cups_queue('Warehouse').with(ensure: 'printer') }

    it { should contain_cups_queue('GroundFloor').with(ensure: 'class', members: %w(Office Warehouse)) }
  end
end
