# encoding: UTF-8
require 'spec_helper'

describe 'cups::default_queue' do
  context 'without attribute `queue`' do
    it { expect { should compile }.to raise_error(/queue/) }
  end

  context "with queue = 'Office'" do
    let(:params) { { queue: 'Office' } }

    it { should contain_class('cups::default_queue').with(queue: 'Office') }

    it { is_expected.to contain_exec('lpadmin-d-Office') }
  end
end
