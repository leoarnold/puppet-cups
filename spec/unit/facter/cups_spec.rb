# encoding: UTF-8
require 'spec_helper'
require 'lib/facter/cups'

def mock_queues_lines(printers, classmembers)
  queues_result = instance_double(PuppetX::Cups::Server::IppResult)
  allow(queues_result).to receive(:lines).and_return(printers + classmembers.keys)
  allow(PuppetX::Cups::Server::IppResult).to receive(:new).with(PuppetX::Cups::Facts::Queues.request).and_return(queues_result)
end

def mock_classmembers_lines(classmembers)
  classmembers_result = instance_double(PuppetX::Cups::Server::IppResult)
  allow(classmembers_result).to receive(:lines).and_return(classmembers_lines(classmembers))
  allow(PuppetX::Cups::Server::IppResult).to receive(:new).and_return(classmembers_result)
end

def classmembers_lines(classmembers)
  response = []
  classmembers.keys.each do |queue|
    members = classmembers[queue].join(',')
    members = '"' + members + '"' if members.include? ','
    response.push(queue + ',' + members)
  end
  response
end

describe PuppetX::Cups::Facts do
  before(:each) do
    described_class.add_facts
  end

  after(:each) do
    Facter.clear
    Facter.clear_messages
  end

  describe '$::cups_classes' do
    let(:fact) { Facter.value(:cups_classes) }

    context 'upon failure' do
      it 'defaults to an empty array' do
        allow(Open3).to receive(:capture3).and_raise('failure')

        expect(fact).to eq([])
      end
    end

    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = []

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
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

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end
  end

  describe '$::cups_classmembers' do
    let(:fact) { Facter.value(:cups_classmembers) }

    context 'upon failure' do
      it 'defaults to an empty hash' do
        allow(Open3).to receive(:capture3).and_raise('failure')

        expect(fact).to eq({})
      end
    end

    context 'with no classes installed' do
      it 'returns an empty hash' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = {}

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
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

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end
  end

  describe '$::cups_printers' do
    let(:fact) { Facter.value(:cups_printers) }

    context 'upon failure' do
      it 'defaults to an empty array' do
        allow(Open3).to receive(:capture3).and_raise('failure')

        expect(fact).to eq([])
      end
    end

    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = %w(BackOffice Office Warehouse)

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
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

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end
  end

  describe '$::cups_queues' do
    let(:fact) { Facter.value(:cups_queues) }

    context 'upon failure' do
      it 'defaults to an empty array' do
        allow(Open3).to receive(:capture3).and_raise('failure')

        expect(fact).to eq([])
      end
    end

    context 'without queues installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
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

        mock_classmembers_lines(classmembers)
        mock_queues_lines(printers, classmembers)
        expect(fact).to match_array(expected)
      end
    end
  end
end
