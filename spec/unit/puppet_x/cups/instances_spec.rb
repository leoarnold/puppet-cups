require 'spec_helper'
require 'lib/puppet_x/cups/instances'

def cups_get_printers
  response = PuppetX::Cups::Ipp::Response.new(yield)
  allow(PuppetX::Cups::Ipp).to receive(:query)
    .with(PuppetX::Cups::Instances::Queues.request)
    .and_return(response)
end

def cups_get_classes
  response = PuppetX::Cups::Ipp::Response.new(yield)
  allow(PuppetX::Cups::Ipp).to receive(:query)
    .with(PuppetX::Cups::Instances::ClassMembers.request)
    .and_return(response)
end

describe PuppetX::Cups::Instances::Classes do
  describe '#to_a' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
          EOT
        end

        expectation = []

        expect(described_class.to_a).to match_array(expectation)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
Office
Warehouse
          EOT
        end

        expectation = []

        expect(described_class.to_a).to match_array(expectation)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        cups_get_classes do <<-EOT
printer-name,member-names
CrawlSpace,
GroundFloor,"Office,Warehouse"
UpperFloor,BackOffice
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
CrawlSpace
GroundFloor
Office
UpperFloor
Warehouse
          EOT
        end

        expectation = %w(CrawlSpace GroundFloor UpperFloor)

        expect(described_class.to_a).to match_array(expectation)
      end
    end
  end
end

describe PuppetX::Cups::Instances::ClassMembers do
  describe '#to_h' do
    context 'with no classes installed' do
      it 'returns an empty hash' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
Office
Warehouse
          EOT
        end

        expectation = {}

        expect(described_class.to_h).to match_array(expectation)
      end
    end

    context 'with classes installed' do
      it 'returns the correct hash' do
        cups_get_classes do <<-EOT
printer-name,member-names
CrawlSpace,
GroundFloor,"Office,Warehouse"
UpperFloor,BackOffice
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
CrawlSpace
GroundFloor
Office
UpperFloor
Warehouse
          EOT
        end

        expectation = {
          'CrawlSpace'  => %w(),
          'GroundFloor' => %w(Office Warehouse),
          'UpperFloor'  => %w(BackOffice)
        }

        expect(described_class.to_h).to match_array(expectation)
      end
    end
  end
end

describe PuppetX::Cups::Instances::Printers do
  describe '#to_a' do
    context 'without printers or classes installed' do
      it 'returns an empty array' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
          EOT
        end

        expectation = []

        expect(described_class.to_a).to match_array(expectation)
      end
    end

    context 'with printers, but without classes installed' do
      it 'returns an array with the names of all installed printers' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
Office
Warehouse
          EOT
        end

        expectation = %w(BackOffice Office Warehouse)

        expect(described_class.to_a).to match_array(expectation)
      end
    end

    context 'with printers and classes installed' do
      it 'returns an array with the names of all installed printers, including classes' do
        cups_get_classes do <<-EOT
printer-name,member-names
CrawlSpace,
GroundFloor,"Office,Warehouse"
UpperFloor,BackOffice
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
CrawlSpace
GroundFloor
Office
UpperFloor
Warehouse
          EOT
        end

        expectation = %w(BackOffice Office Warehouse)

        expect(described_class.to_a).to match_array(expectation)
      end
    end
  end
end

describe PuppetX::Cups::Instances::Queues do
  describe '#to_a' do
    context 'without queues installed' do
      it 'returns an empty array' do
        cups_get_classes do <<-EOT
printer-name,member-names
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
          EOT
        end

        expectation = []

        expect(described_class.to_a).to match_array(expectation)
      end
    end

    context 'with queues installed' do
      it 'returns an array with the names of all installed queues' do
        cups_get_classes do <<-EOT
printer-name,member-names
CrawlSpace,
GroundFloor,"Office,Warehouse"
UpperFloor,BackOffice
          EOT
        end

        cups_get_printers do <<-EOT
printer-name
BackOffice
CrawlSpace
GroundFloor
Office
UpperFloor
Warehouse
          EOT
        end

        expectation = %w(CrawlSpace BackOffice GroundFloor Office UpperFloor Warehouse)

        expect(described_class.to_a).to match_array(expectation)
      end
    end
  end
end
