require 'spec_helper'

describe Puppet::Type.type(:cups_queue).provider(:cups) do
  let(:type) { Puppet::Type.type(:cups_queue) }
  let(:provider) { described_class }

  context 'when managing a class' do
    before(:each) do
      manifest = {
        ensure: 'class',
        name: 'GroundFloor',
        members: %w(Office Warehouse)
      }

      @resource = type.new(manifest)
      @provider = provider.new(@resource)
    end

    describe '#class_exists?' do
      it 'returns true if a class by that name exists' do
        expect(Facter).to receive(:value).with(:cups_classes).and_return(%w(GroundFloor UpperFloor))
        expect(@provider.class_exists?).to be true
      end

      it 'returns false if no class by that name exists' do
        expect(Facter).to receive(:value).with(:cups_classes).and_return(%w(UpperFloor))
        expect(@provider.class_exists?).to be false
      end
    end

    describe '#create_class' do
      it 'installs the class' do
        expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-c', 'GroundFloor')
        expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Warehouse', '-c', 'GroundFloor')
        @provider.create_class
      end
    end

    describe '#destroy' do
      it 'deletes the printer' do
        expect(@provider).to receive(:lpadmin).with('-E', '-x', 'GroundFloor')
        @provider.destroy
      end
    end
  end

  context 'when managing a printer' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/generic.ppd',
        uri: 'lpd://192.168.2.105/binary_p1'
      }

      @resource = type.new(manifest)
      @provider = provider.new(@resource)
    end

    describe '#printer_exists?' do
      it 'returns true if a printer by that name exists' do
        expect(Facter).to receive(:value).with(:cups_printers).and_return(%w(BackOffice Office Warehouse))
        expect(@provider.printer_exists?).to be true
      end

      it 'returns false if no printer by that name exists' do
        expect(Facter).to receive(:value).with(:cups_printers).and_return(%w(BackOffice Warehouse))
        expect(@provider.printer_exists?).to be false
      end
    end

    describe '#create_printer' do
      it 'installs the printer' do
        expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-m', 'drv:///sample.drv/generic.ppd')
        expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-v', 'lpd://192.168.2.105/binary_p1')
        @provider.create_printer
      end
    end

    describe '#destroy' do
      it 'deletes the printer' do
        expect(@provider).to receive(:lpadmin).with('-E', '-x', 'Office')
        @provider.destroy
      end
    end
  end
end
