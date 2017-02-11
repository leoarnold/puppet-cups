require 'spec_helper'
require 'lib/puppet_x/cups/instances'

def mock_queues_rows(printers, classmembers)
  response_mock = instance_double(PuppetX::Cups::Ipp::Response)
  allow(response_mock).to receive(:rows).and_return(printers + classmembers.keys)
  allow(PuppetX::Cups::Ipp).to receive(:query).with(PuppetX::Cups::Instances::Queues.request).and_return(response_mock)
end

def mock_classmembers_rows(classmembers)
  response_mock = instance_double(PuppetX::Cups::Ipp::Response)
  allow(response_mock).to receive(:rows).and_return(classmembers_rows(classmembers))
  allow(PuppetX::Cups::Ipp).to receive(:query).with(PuppetX::Cups::Instances::ClassMembers.request).and_return(response_mock)
end

def classmembers_rows(classmembers)
  response = []
  classmembers.keys.each do |queue|
    members = classmembers[queue].join(',')
    members = '"' + members + '"' if members.include? ','
    response.push(queue + ',' + members)
  end
  response
end

describe PuppetX::Cups::Instances::Classes do
  describe '#to_a' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = []

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        classmembers = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }
        printers = %w(BackOffice Office Warehouse)
        expected = %w(CrawlSpace GroundFloor UpperFloor)

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end
  end
end

describe PuppetX::Cups::Instances::ClassMembers do
  describe '#to_h' do
    context 'with no classes installed' do
      it 'returns an empty hash' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = {}

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_h).to match_array(expected)
      end
    end

    context 'with classes installed' do
      it 'returns the correct hash' do
        classmembers = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }
        printers = %w(BackOffice Office Warehouse)
        expected = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_h).to match_array(expected)
      end
    end
  end
end

describe PuppetX::Cups::Instances::Printers do
  describe '#to_a' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = %w(BackOffice Office Warehouse)

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        classmembers = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }
        printers = %w(BackOffice Office Warehouse)
        expected = %w(BackOffice Office Warehouse)

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end
  end
end

describe PuppetX::Cups::Instances::Queues do
  describe '#to_a' do
    context 'without queues installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end

    context 'with queues installed' do
      it 'returns an array with the names of all installed queues' do
        classmembers = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }
        printers = %w(BackOffice Office Warehouse)
        expected = %w(CrawlSpace BackOffice GroundFloor Office UpperFloor Warehouse)

        mock_classmembers_rows(classmembers)
        mock_queues_rows(printers, classmembers)
        expect(described_class.to_a).to match_array(expected)
      end
    end
  end
end
