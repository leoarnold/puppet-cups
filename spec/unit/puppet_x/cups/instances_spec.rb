# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/instances'

def cups_get_printers(stdout)
  mock_shellout = double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)

  allow(PuppetX::Cups::Shell).to receive(:ipptool).and_return(mock_shellout)
    .with('-c', '/', PuppetX::Cups::Instances.cups_get_printers).and_return(mock_shellout)
end

def cups_get_classes(stdout)
  mock_shellout = double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)

  allow(PuppetX::Cups::Shell).to receive(:ipptool)
    .with('-c', '/', PuppetX::Cups::Instances.cups_get_classes).and_return(mock_shellout)
end

RSpec.describe PuppetX::Cups::Instances do
  describe '##classes' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT

        expectation = []

        expect(described_class.classes).to match_array(expectation)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          Office
          Warehouse
        OUTPUT

        expectation = []

        expect(described_class.classes).to match_array(expectation)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
          CrawlSpace,
          GroundFloor,"Office,Warehouse"
          UpperFloor,BackOffice
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          CrawlSpace
          GroundFloor
          Office
          UpperFloor
          Warehouse
        OUTPUT

        expectation = %w[CrawlSpace GroundFloor UpperFloor]

        expect(described_class.classes).to match_array(expectation)
      end
    end
  end

  describe '##classmembers' do
    context 'with no classes installed' do
      it 'returns an empty hash' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          Office
          Warehouse
        OUTPUT

        expectation = {}

        expect(described_class.classmembers).to match_array(expectation)
      end
    end

    context 'with classes installed' do
      it 'returns the correct hash' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
          CrawlSpace,
          GroundFloor,"Office,Warehouse"
          UpperFloor,BackOffice
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          CrawlSpace
          GroundFloor
          Office
          UpperFloor
          Warehouse
        OUTPUT

        expectation = {
          'CrawlSpace'  => %w[],
          'GroundFloor' => %w[Office Warehouse],
          'UpperFloor'  => %w[BackOffice]
        }

        expect(described_class.classmembers).to match_array(expectation)
      end
    end
  end

  describe '##printers' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT

        expectation = []

        expect(described_class.printers).to match_array(expectation)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          Office
          Warehouse
        OUTPUT

        expectation = %w[BackOffice Office Warehouse]

        expect(described_class.printers).to match_array(expectation)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
          CrawlSpace,
          GroundFloor,"Office,Warehouse"
          UpperFloor,BackOffice
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          CrawlSpace
          GroundFloor
          Office
          UpperFloor
          Warehouse
        OUTPUT

        expectation = %w[BackOffice Office Warehouse]

        expect(described_class.printers).to match_array(expectation)
      end
    end
  end

  describe '##queues' do
    context 'without queues installed' do
      it 'returns an empty array' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT

        expectation = []

        expect(described_class.queues).to match_array(expectation)
      end
    end

    context 'with queues installed' do
      it 'returns an array with the names of all installed queues' do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
          CrawlSpace,
          GroundFloor,"Office,Warehouse"
          UpperFloor,BackOffice
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          CrawlSpace
          GroundFloor
          Office
          UpperFloor
          Warehouse
        OUTPUT

        expectation = %w[CrawlSpace BackOffice GroundFloor Office UpperFloor Warehouse]

        expect(described_class.queues).to match_array(expectation)
      end
    end
  end
end
