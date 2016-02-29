require 'spec_helper'

describe 'cups::directive' do
  let(:title) { 'WebInterface' }

  context 'without attribute value' do
    it { expect { should compile }.to raise_error(/value/) }
  end

  context 'with attribute value' do
    let(:params) { { value: 'true' } }

    it { expect { should compile }.to raise_error(/private/) }
  end
end
