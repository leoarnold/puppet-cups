require 'spec_helper'

describe 'gibbons.initech.com' do
  let(:facts) { any_supported_os(certname: 'gibbons.initech.com') }

  let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

  context 'using a hiera example' do
    it { should contain_node('gibbons.initech.com') }

    it { should contain_class('cups').with(web_interface: false) }

    it { should contain_cups_queue('Warehouse').with(ensure: 'printer') }
  end
end
