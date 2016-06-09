# encoding: UTF-8
require 'spec_helper'
require 'lib/puppet_x/cups/server'

describe PuppetX::Cups::Server do
  describe '#ipptool' do
    context 'when exitstatus is NOT zero' do
      it 'raises an error' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(1)
        expect(Open3).to receive(:capture3).and_return(['', '', status_mock])

        expect { described_class.ipptool('{ Mock request }', '/') }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#query' do
    context 'without argument "resource"' do
      it 'defaults to "/"' do
        request = '{ Mock request }'

        expect(described_class).to receive(:ipptool).with('/', request).and_return('')
        described_class.query(request)
      end
    end

    context 'when #ipptool fails' do
      it 'raises an error and provides useful information' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(1)
        expect(Open3).to receive(:capture3).and_return(["Headline\nLine1\nLine2\n", '', status_mock])

        expect { described_class.query('{ Mock request }', '/printers/Office') }.to raise_error(/Office.*Mock request/m)
      end
    end

    context 'when #ipptool succeeds' do
      it 'returns an array of all stdout lines except the headline' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(0)
        expect(Open3).to receive(:capture3).and_return(["Headline\nLine1\nLine2\n", '', status_mock])

        expect(described_class.query('{ Mock request }')).to match_array(%w(Line1 Line2))
      end

      it 'returns an empty array upon a headline-only response' do
        status_mock = instance_double(Process::Status)
        expect(status_mock).to receive(:exitstatus).and_return(0)
        expect(Open3).to receive(:capture3).and_return(["Headline\n", '', status_mock])

        expect(described_class.query('{ Mock request }')).to match_array([])
      end
    end
  end
end
