# frozen_string_literal: true

require 'spec_helper'

describe 'cups::queues' do
  context 'with default values for all parameters' do
    let(:facts) { any_supported_os }

    it { should contain_class('cups::queues::default') }

    it { should contain_class('cups::queues::resources') }

    it { should contain_class('cups::queues::unmanaged') }
  end
end
