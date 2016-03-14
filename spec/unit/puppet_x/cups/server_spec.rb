# encoding: UTF-8
require 'spec_helper'
require 'lib/puppet_x/cups/server'

describe PuppetX::Cups::Server::IppResult do
  describe '#query' do
    context 'when command execution fails' do
      it 'raises an error' do
        expect(Open3).to receive(:capture3).and_raise(StandardError.new('Mock error'))
        expect { described_class.new('Mock request') }.to raise_error(/ipptool/)
      end
    end
  end

  describe '#new' do
    context 'when exitstatus is zero' do
      it 'returns an empty array upon a single line response' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(0)
        expect(Open3).to receive(:capture3).and_return(['Headline\nLine1\nLine2\n', '', status_mock])
        described_class.new('Mock request')
      end
    end

    context 'when exitstatus is NOT zero' do
      it 'raises an error' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(1)
        expect(Open3).to receive(:capture3).and_return(['Headline\nLine1\nLine2\n', '', status_mock])
        expect { described_class.new('Mock request') }.to raise_error(/CUPS server/)
      end
    end
  end

  describe '#lines' do
    context 'when exitstatus is zero' do
      it 'returns an array of all stdout lines except the headline' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(0)
        expect(Open3).to receive(:capture3).and_return(["Headline\nLine1\nLine2\n", '', status_mock])
        expect(described_class.new('Mock request').lines).to match_array(%w(Line1 Line2))
      end

      it 'returns an empty array upon a single line response to stdout' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(0)
        expect(Open3).to receive(:capture3).and_return(['Headline\n', '', status_mock])
        expect(described_class.new('Mock request').lines).to match_array([])
      end
    end
  end
end
