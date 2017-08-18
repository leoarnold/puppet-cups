# frozen_string_literal: true

require 'spec_helper'

describe 'cups::server' do
  context 'with default values for all parameters' do
    let(:facts) { any_supported_os }

    it { should contain_class('cups::server::config').that_notifies('Class[cups::server::services]') }

    it { should contain_class('cups::server::services') }
  end
end
