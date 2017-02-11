require 'spec_helper'
require 'lib/puppet_x/cups/ipp'

describe PuppetX::Cups::Ipp do
  describe '#query' do
    it '' do
      request = '{ [IPP request] }'

      status_mock = instance_double(Process::Status)
      allow(status_mock).to receive(:exitstatus).and_return(0)
      allow(Open3).to receive(:capture3)
        .with('ipptool -c ipp://localhost/ /dev/stdin', stdin_data: request)
        .and_return(["printer-name\nOffice\nWarehouse\n", '', status_mock])

      response = described_class.query(request)
      expect(response.rows).to match(%w(Office Warehouse))
    end
  end

  describe described_class::Response do
    describe '#stdout_lines' do
      context "when stdout = ''" do
        it 'returns an empty array' do
          response = described_class.new('')
          expect(response.stdout_lines).to match_array([])
        end
      end

      context "when stdout = 'Microphone check\\nOne\\nTwo\\n'" do
        it "returns ['Microphone check', 'One', 'Two']" do
          response = described_class.new("Microphone check\nOne\nTwo\n")
          expect(response.stdout_lines).to match_array(['Microphone check', 'One', 'Two'])
        end
      end
    end

    describe '#rows' do
      context "when stdout = ''" do
        it 'returns nil' do
          response = described_class.new('')
          expect(response.rows).to be nil
        end
      end

      context "when stdout = 'Microphone check\\n" do
        it 'returns []' do
          response = described_class.new("Microphone check\n")
          expect(response.rows).to match_array([])
        end
      end

      context "when stdout = 'Microphone check\\nOne\\nTwo\\n'" do
        it "returns ['One', 'Two']" do
          response = described_class.new("Microphone check\nOne\nTwo\n")
          expect(response.rows).to match_array(%w(One Two))
        end
      end
    end

    describe '#first_row' do
      context "when stdout = ''" do
        it 'returns nil' do
          response = described_class.new('')
          expect(response.first_row).to be nil
        end
      end

      context "when stdout = 'Microphone check\\n" do
        it 'returns nil' do
          response = described_class.new("Microphone check\n")
          expect(response.first_row).to be nil
        end
      end

      context "when stdout = 'Microphone check\\nOne\\nTwo\\n'" do
        it "returns 'One'" do
          response = described_class.new("Microphone check\nOne\nTwo\n")
          expect(response.first_row).to eq('One')
        end
      end
    end
  end

  describe described_class::Execution do
    let(:query_class) { PuppetX::Cups::Ipp::Query }
    let(:error_class) { PuppetX::Cups::Ipp::Error }

    context 'when execution was successful' do
      context 'and returned output' do
        it "provides the command's stdout" do
          query = query_class.new('/printers/Office', '{ [IPP request] }')
          stdout = "printer-location\nRoom 101\n"

          status_mock = instance_double(Process::Status)
          allow(status_mock).to receive(:exitstatus).and_return(0)
          allow(Open3).to receive(:capture3).and_return([stdout, '', status_mock])

          execution = described_class.new(query)
          expect(execution.stdout).to eq(stdout)
        end
      end

      context 'and stdout was empty' do
        # Related issue: https://github.com/leoarnold/puppet-cups/issues/12
        it 'raises an error' do
          query = query_class.new('/printers/Office', '{ [IPP request] }')
          stdout = ''

          status_mock = instance_double(Process::Status)
          allow(status_mock).to receive(:exitstatus).and_return(0)
          allow(Open3).to receive(:capture3).and_return([stdout, '', status_mock])

          expect { described_class.new(query) }.to raise_error(error_class)
        end
      end
    end

    context 'when execution fails' do
      it 'raises an error' do
        query = query_class.new('', '{ [IPP request] }')

        status_mock = instance_double(Process::Status)
        allow(status_mock).to receive(:exitstatus).and_return(1)
        allow(Open3).to receive(:capture3).and_return(['', '', status_mock])

        expect { described_class.new(query) }.to raise_error(error_class)
      end
    end
  end

  describe described_class::Error do
    let(:query_class) { PuppetX::Cups::Ipp::Query }

    it 'provides a comprehensive error message' do
      query = query_class.new('/things/Office', '[IPP request]')
      stdout = "In this case, there would be no output.\n"
      stderr = "ipptool: Unable to connect to localhost on port 631 - Transport endpoint is not connected\n"

      expect { raise described_class.new(query, stdout, stderr) }.to raise_error(/#{query.uri}/)
      expect { raise described_class.new(query, stdout, stderr) }.to raise_error(/#{query.request}/)
      expect { raise described_class.new(query, stdout, stderr) }.to raise_error(/#{stdout}/)
      expect { raise described_class.new(query, stdout, stderr) }.to raise_error(/#{stderr}/)
    end

    # Related issue: https://github.com/leoarnold/puppet-cups/issues/6
    it 'references RFC 2911 when stderr = "successful-ok\n"' do
      query = query_class.new('/printers/Office', '{ [IPP request] }')
      stdout = ''
      stderr = "successful-ok\n"

      expect { raise described_class.new(query, stdout, stderr) }.to raise_error(/RFC 2911/)
    end
  end
end
