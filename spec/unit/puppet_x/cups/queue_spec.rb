# frozen_string_literal: true

require 'spec_helper'
require 'lib/puppet_x/cups/queue'

describe PuppetX::Cups::Queue do
  describe '##attribute' do
  end
end

describe PuppetX::Cups::Queue::Attribute do
  describe '#value' do
    context 'when the query result is an array' do
      it 'returns nil' do
        attribute = described_class.new('Office', 'auth-info-required')

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return([])

        expect(attribute.value).to be nil
      end
    end

    context 'when the query result is a non-empty array' do
      it 'returns the first entry' do
        attribute = described_class.new('Office', 'device-uri')

        allow(PuppetX::Cups::Ipp).to receive(:query).and_return(%w[lpd://192.168.2.105/binary_p1])

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
