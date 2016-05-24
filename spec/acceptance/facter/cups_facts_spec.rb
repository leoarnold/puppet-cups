# encoding: UTF-8
require 'spec_helper_acceptance'

def custom_fact(fact)
  output = shell('puppet apply --color=false -e \'notice("<fact>${::' + fact + '}</fact>")\'').stdout
  result = %r{<fact>(?<value>.*)</fact>}.match(output)
  eval(result[:value].gsub(/\w+/) { |word| "'" + word + "'" }) if result
end

describe 'Custom Facts' do
  before(:all) do
    ensure_cups_is_running
  end

  before(:each) do
    purge_all_queues
  end

  after(:all) do
    purge_all_queues
  end

  describe '$::cups_classes' do
    let(:fact) { 'cups_classes' }

    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = []

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
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

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
      end
    end
  end

  describe '$::cups_classmembers' do
    let(:fact) { 'cups_classmembers' }

    context 'with no classes installed' do
      it 'returns an empty hash' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = {}

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to eq(expected)
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

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to eq(expected)
      end
    end
  end

  describe '$::cups_printers' do
    let(:fact) { 'cups_printers' }

    context 'without printers or classes installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        classmembers = {}
        printers = %w(BackOffice Office Warehouse)
        expected = %w(BackOffice Office Warehouse)

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
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

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
      end
    end
  end

  describe '$::cups_queues' do
    let(:fact) { 'cups_queues' }

    context 'without queues installed' do
      it 'returns an empty array' do
        classmembers = {}
        printers = []
        expected = []

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
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

        add_printers(printers)
        add_printers_to_classes(classmembers)
        expect(custom_fact(fact)).to match_array(expected)
      end
    end
  end
end
