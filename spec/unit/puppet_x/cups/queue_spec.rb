# encoding: UTF-8
require 'spec_helper'
require 'lib/puppet_x/cups/queue'

describe PuppetX::Cups::Queue::Attribute do
  describe '#query' do
    it "uses url encoding and returns the second line of ipptool's output to stdout" do
      request = described_class.request('device-uri')
      process = instance_double(Process::Status)
      expect(process).to receive(:exitstatus).and_return(0)
      expect(Open3).to receive(:capture3) \
        .with('ipptool -c ipp://localhost/printers/%C3%9Cnic%C3%B4de /dev/stdin', stdin_data: request) \
        .and_return(["device-uri\nlpd://192.168.2.105/binary_p1\n", '', process])
      expect(described_class.query('Ünicôde', 'device-uri')).to eq('lpd://192.168.2.105/binary_p1')
    end
  end
end
