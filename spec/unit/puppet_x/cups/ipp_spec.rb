# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/instances'
require 'puppet_x/cups/ipp'

RSpec.describe PuppetX::Cups::Ipp do
  describe 'QueryC' do
    subject(:described_class) { PuppetX::Cups::Ipp::QueryC }

    describe '#new' do
      context 'when the shell command exits 0' do
        it 'creates an object' do
          mock_shellout = instance_double(PuppetX::Cups::Shell::ShellOut, stdout: 'mock stdout', exitcode: 0)

          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', '{ [IPP] }')

          expect(query).to be_a described_class
        end
      end

      context 'when the shell command exits 1' do
        let(:request) { '{ [IPP] }' }
        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut,
                          command: 'mock command',
                          stdin: request,
                          stdout: 'mock stdout',
                          stderr: 'mock stderr',
                          exitcode: 1)
        end

        it 'raises an error' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          expect { described_class.new('/', request) }.to raise_error PuppetX::Cups::Ipp::QueryError
        end
      end
    end

    describe '#results' do
      context 'when stdout is a header-only CSV table' do
        let(:stdout) do
          <<~OUTPUT
            printer-name
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)
        end

        it 'returns an empty array' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', '{ [CUPS-Get-Printers] }')

          expect(query.results).to be_empty
        end
      end

      context 'when stdout is a single-row CSV table' do
        let(:stdout) do
          <<~OUTPUT
            printer-name
            Office
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)
        end

        it 'returns an array containing the row' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', '{ [CUPS-Get-Printers] }')

          expect(query.results).to match_array(%w[Office])
        end
      end

      context 'when stdout is a multi-row CSV table' do
        let(:stdout) do
          <<~OUTPUT
            printer-name
            BackOffice
            Office
            Warehouse
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)
        end

        it 'returns an array containing the rows' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', '{ [CUPS-Get-Printers] }')

          expect(query.results).to match_array(%w[Office BackOffice Warehouse])
        end
      end
    end
  end

  describe 'QueryT' do
    subject(:described_class) { PuppetX::Cups::Ipp::QueryT }

    describe '#new' do
      context 'when stdout contains "status-code = successful-ok"' do
        context 'when the shell command exits 0' do
          let(:mock_shellout) do
            instance_double(PuppetX::Cups::Shell::ShellOut, stdout: 'status-code = successful-ok', exitcode: 0)
          end

          it 'creates an object' do
            allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

            query = described_class.new('/', '{ [IPP] }')

            expect(query).to be_a described_class
          end
        end

        context 'when the shell command exits 1' do
          let(:mock_shellout) do
            instance_double(PuppetX::Cups::Shell::ShellOut, stdout: 'status-code = successful-ok', exitcode: 1)
          end

          it 'creates an object' do
            allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

            query = described_class.new('/', '{ [IPP] }')

            expect(query).to be_a described_class
          end
        end
      end

      context 'when stdout does NOT contain "status-code = successful-ok"' do
        context 'when the shell command exits 0' do
          let(:mock_shellout) do
            instance_double(PuppetX::Cups::Shell::ShellOut, stdout: 'mock stdout', exitcode: 0)
          end

          it 'creates an object' do
            allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

            query = described_class.new('/', '{ [IPP] }')

            expect(query).to be_a described_class
          end
        end

        context 'when the shell command exits 1' do
          let(:request) { '{ [IPP] }' }

          let(:mock_shellout) do
            instance_double(PuppetX::Cups::Shell::ShellOut,
                            command: 'mock command',
                            stdin: request,
                            stdout: 'mock stdout',
                            stderr: 'mock stderr',
                            exitcode: 1)
          end

          it 'raises an error' do
            allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

            expect { described_class.new('/', request) }.to raise_error PuppetX::Cups::Ipp::QueryError
          end
        end
      end
    end

    describe '#results' do
      context 'when stdout does not contain the attribute' do
        let(:request) do
          PuppetX::Cups::Instances.cups_get_printers
        end

        let(:stdout) do
          <<~OUTPUT
            "CUPS-Get-Printers.ipp":
                CUPS-Get-Printers                                                    [PASS]
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdin: request, stdout: stdout, exitcode: 0)
        end

        it 'returns an empty array' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', request)

          expect(query.results).to be_empty
        end
      end

      context 'when stdout contains a single occurance of the attribute' do
        let(:request) do
          PuppetX::Cups::Instances.cups_get_printers
        end

        let(:stdout) do
          <<~OUTPUT
            "CUPS-Get-Printers.ipp":
                CUPS-Get-Printers                                                    [FAIL]
                    RECEIVED: 8084 bytes in response
                    status-code = successful-ok (successful-ok)
                    Duplicate "pwg-raster-document-type-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-resolution-supported" attribute in printer-attributes-tag group
                    printer-name (nameWithoutLanguage) = Office
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdin: request, stdout: stdout, exitcode: 0)
        end

        it 'returns an array containing the attribute value' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', request)

          expect(query.results).to match_array(%w[Office])
        end
      end

      context 'when stdout contains multiple occurance of the attribute' do
        let(:request) do
          PuppetX::Cups::Instances.cups_get_printers
        end

        let(:stdout) do
          <<~OUTPUT
            "CUPS-Get-Printers.ipp":
                CUPS-Get-Printers                                                    [FAIL]
                    RECEIVED: 24143 bytes in response
                    status-code = successful-ok (successful-ok)
                    Duplicate "pwg-raster-document-type-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-resolution-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-type-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-resolution-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-type-supported" attribute in printer-attributes-tag group
                    Duplicate "pwg-raster-document-resolution-supported" attribute in printer-attributes-tag group
                    printer-name (nameWithoutLanguage) = BackOffice
                    printer-name (nameWithoutLanguage) = Office
                    printer-name (nameWithoutLanguage) = Warehouse
          OUTPUT
        end

        let(:mock_shellout) do
          instance_double(PuppetX::Cups::Shell::ShellOut, stdin: request, stdout: stdout, exitcode: 0)
        end

        it 'returns an array containing the attribute values' do
          allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)

          query = described_class.new('/', request)

          expect(query.results).to match_array(%w[Office BackOffice Warehouse])
        end
      end
    end
  end
end
