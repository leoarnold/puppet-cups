require 'spec_helper'

describe 'cups' do
  package_name = 'cups'
  service_name = 'cups'

  context 'with defaults for all parameters' do
    it { should contain_class('cups') }

    it { is_expected.to contain_package(package_name).with(ensure: 'present') }

    it { is_expected.to contain_service(service_name).with(ensure: 'running', enable: 'true') }
  end
end
