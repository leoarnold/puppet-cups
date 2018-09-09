# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'cups::queues' do
  context 'with default values for all parameters' do
    let(:facts) { any_supported_os }

    it { is_expected.to contain_class('cups::queues::default') }

    it { is_expected.to contain_class('cups::queues::resources') }

    it { is_expected.to contain_class('cups::queues::unmanaged') }
  end
end
