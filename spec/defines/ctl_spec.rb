# encoding: UTF-8
require 'spec_helper'

describe 'cups::ctl' do
  let(:title) { 'WebInterface' }

  context 'with attribute' do
    context 'ensure' do
      context 'not specified' do
        it { expect { should compile }.to raise_error(/ensure/) }
      end

      context 'specified' do
        let(:params) { { ensure: 'Yes' } }

        it { should contain_exec("cupsctl-#{title}").with(command: "cupsctl -E #{title}=Yes") }
      end
    end
  end
end
