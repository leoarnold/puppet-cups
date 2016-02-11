require 'spec_helper'

describe 'cups::default_queue' do
  context 'without attribute queue' do
    it { expect { should compile }.to raise_error(/queue/) }
  end

  context 'with attribute queue' do
    let(:params) { { queue: 'Office' } }

    it { expect { should compile }.to raise_error(/private/) }
  end
end
