# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/instances'

def cups_get_printers(stdout)
  mock_shellout = instance_double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)

  allow(PuppetX::Cups::Shell).to receive(:ipptool)
    .with('-c', '/', PuppetX::Cups::Instances.cups_get_printers)
    .and_return(mock_shellout)
end

def cups_get_classes(stdout)
  mock_shellout = instance_double(PuppetX::Cups::Shell::ShellOut, stdout: stdout, exitcode: 0)

  allow(PuppetX::Cups::Shell).to receive(:ipptool)
    .with('-c', '/', PuppetX::Cups::Instances.cups_get_classes)
    .and_return(mock_shellout)
end

RSpec.describe PuppetX::Cups::Instances do
  describe '##classes' do
    context 'without printers or classes installed' do
      before do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT
      end

      it 'returns an empty array' do
        expect(described_class.classes).to match_array([])
      end
    end

    context 'with printers, but without classes installed' do
      before do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          Office
          Warehouse
        OUTPUT
      end

      it 'returns an array with the names of all installed printers' do
        expect(described_class.classes).to match_array([])
      end
    end

    context 'with printers and classes installed' do
      before do
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
      end

      it 'returns an array with the names of all installed printers, including classes' do
        expect(described_class.classes).to match_array(%w[CrawlSpace GroundFloor UpperFloor])
      end
    end
  end

  describe '##class_members' do
    context 'with no classes installed' do
      before do
        cups_get_classes <<~OUTPUT
            printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
            printer-name
            BackOffice
            Office
            Warehouse
        OUTPUT
      end

      it 'returns an empty hash' do
        expect(described_class.class_members).to match_array({})
      end
    end

    context 'with classes installed' do
      before do
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
      end

      let(:expected) do
        {
          'CrawlSpace' => %w[],
          'GroundFloor' => %w[Office Warehouse],
          'UpperFloor' => %w[BackOffice]
        }
      end

      it 'returns the correct hash' do
        expect(described_class.class_members).to match_array(expected)
      end
    end
  end

  describe '##printers' do
    context 'without printers or classes installed' do
      before do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT
      end

      it 'returns an empty array' do
        expect(described_class.printers).to match_array([])
      end
    end

    context 'with printers, but without classes installed' do
      before do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
          BackOffice
          Office
          Warehouse
        OUTPUT
      end

      it 'returns an array with the names of all installed printers' do
        expect(described_class.printers).to match_array(%w[BackOffice Office Warehouse])
      end
    end

    context 'with printers and classes installed' do
      before do
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
      end

      it 'returns an array with the names of all installed printers, including classes' do
        expect(described_class.printers).to match_array(%w[BackOffice Office Warehouse])
      end
    end
  end

  describe '##queues' do
    context 'without queues installed' do
      before do
        cups_get_classes <<~OUTPUT
          printer-name,member-names
        OUTPUT

        cups_get_printers <<~OUTPUT
          printer-name
        OUTPUT
      end

      it 'returns an empty array' do
        expect(described_class.queues).to match_array([])
      end
    end

    context 'with queues installed' do
      before do
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
      end

      it 'returns an array with the names of all installed queues' do
        expect(described_class.queues).to match_array(%w[CrawlSpace BackOffice GroundFloor Office UpperFloor Warehouse])
      end
    end
  end
end
