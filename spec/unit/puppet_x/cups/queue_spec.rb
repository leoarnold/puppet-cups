# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/queue'

RSpec.describe PuppetX::Cups::Queue do
  describe '##attribute' do
  end
end

RSpec.describe PuppetX::Cups::Queue::Attribute do
  describe '#value' do
    context 'when the query result is an empty array' do
      it 'returns an empty string' do
        attribute = described_class.new('Office', 'auth-info-required')

        mock_query = double(PuppetX::Cups::Ipp::QueryC, results: [])

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return(mock_query)

        expect(attribute.value).to eq ''
      end
    end

    context 'when the query result is a non-empty array' do
      it 'returns the first entry and strips surrounding quotes' do
        attribute = described_class.new('Office', 'printer-make-and-model')

        mock_query = double(PuppetX::Cups::Ipp::QueryC, results: ['"HP Color LaserJet 4730mfp pcl3, hpcups 3.14.3"'])

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return(mock_query)

        expect(attribute.value).to eq 'HP Color LaserJet 4730mfp pcl3, hpcups 3.14.3'
      end
    end
  end

  describe '#resource' do
    it 'uses url encoding' do
      attribute = described_class.new('Üni&côde', 'device-uri')

      expect(attribute.send(:resource)).to eq '/printers/%C3%9Cni%26c%C3%B4de'
    end
  end
end
