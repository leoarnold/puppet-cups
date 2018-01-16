# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/queue'

RSpec.describe PuppetX::Cups::Queue do
  describe '##attribute' do
  end
end

RSpec.describe PuppetX::Cups::Queue::Attribute do
  describe '#value' do
    context 'when the query result is an array' do
      it 'returns an empty string' do
        attribute = described_class.new('Office', 'auth-info-required')

        mock_query = double(PuppetX::Cups::Ipp::QueryC, results: [])

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return(mock_query)

        expect(attribute.value).to eq ''
      end
    end

    context 'when the query result is a non-empty array' do
      it 'returns the first entry' do
        attribute = described_class.new('Office', 'device-uri')

        mock_query = double(PuppetX::Cups::Ipp::QueryC, results: %w[lpd://192.168.2.105/binary_p1])

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return(mock_query)

        expect(attribute.value).to eq 'lpd://192.168.2.105/binary_p1'
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
