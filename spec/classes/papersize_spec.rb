# encoding: UTF-8
require 'spec_helper'

describe 'cups::papersize' do
  context 'without attribute `papersize`' do
    it { expect { should compile }.to raise_error(/papersize/) }
  end

  context "with papersize = 'a4'" do
    let(:params) { { papersize: 'a4' } }

    it { should contain_class('cups::papersize').with(papersize: 'a4') }

    it { is_expected.to contain_exec('paperconfig-p-a4').with(command: 'paperconfig -p a4') }
  end
end
