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
        expect(described_class).to receive(:cups_classes).and_return(%w(GroundFloor UpperFloor))
        expect(@provider.class_exists?).to be true
      end

      it 'returns false if no class by that name exists' do
        expect(described_class).to receive(:cups_classes).and_return(%w(UpperFloor))
        expect(@provider.class_exists?).to be false
      end
    end

    describe '#create_class' do
      context 'using the minimal manifest' do
        it 'installs the class with default values' do
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-c', 'GroundFloor')
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Warehouse', '-c', 'GroundFloor')
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'GroundFloor', '-o', 'printer-is-shared=false')

          @provider.create_class
        end
      end
    end

    describe '#destroy' do
      it 'deletes the class if it exists' do
        allow(@provider).to receive(:queue_exists?).and_return(true)
        expect(@provider).to receive(:lpadmin).with('-E', '-x', 'GroundFloor')

        @provider.destroy
      end
    end
  end

  context 'when managing a printer' do
    shared_examples 'provider contract' do |manifest|
      before(:each) do
        @resource = type.new(manifest)
        @provider = provider.new(@resource)
      end

      describe '#printer_exists?' do
        it 'returns true if a printer by that name exists' do
          expect(described_class).to receive(:cups_printers).and_return(%w(BackOffice Office Warehouse))
          expect(@provider.printer_exists?).to be true
        end

        it 'returns false if no printer by that name exists' do
          expect(described_class).to receive(:cups_printers).and_return(%w(BackOffice Warehouse))
          expect(@provider.printer_exists?).to be false
        end
      end

      describe '#create_printer' do
        it 'installs the printer with default vaules' do
          switch = { interface: '-i', model: '-m', ppd: '-P' }
          method = (manifest.keys & switch.keys)[0]

          allow(@provider).to receive(:lpadmin).with('-E', '-x', 'Office')
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-v', '/dev/null')
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', switch[method], manifest[method]) if method
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-o', 'printer-is-shared=false')

          @provider.create_printer
        end
      end

      describe '#destroy' do
        it 'deletes the printer if it exists' do
          allow(@provider).to receive(:queue_exists?).and_return(true)
          expect(@provider).to receive(:lpadmin).with('-E', '-x', 'Office')

          @provider.destroy
        end
      end
    end

    describe 'as raw queue' do
      manifest = {
        ensure: 'printer',
        name: 'Office'
      }

      include_examples 'provider contract', manifest
    end

    describe 'using a model' do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/deskjet.ppd'
      }

      include_examples 'provider contract', manifest
    end

    describe 'using a PPD file' do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        ppd: '/usr/share/ppd/cupsfilters/textonly.ppd'
      }

      include_examples 'provider contract', manifest
    end

    describe 'using a System V interface script' do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        interface: '/usr/share/cups/model/myprinter.sh'
      }

      include_examples 'provider contract', manifest
    end
  end

  describe 'provider methods' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office'
      }

      @resource = type.new(manifest)
      @provider = provider.new(@resource)
    end

    describe '#access' do
      context 'when no policy is in place' do
        it 'returns all users allowed' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return(nil)
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return(nil)

          expect(@provider.access).to eq('policy' => 'allow', 'users' => ['all'])
        end
      end

      context 'when an allow policy is in place' do
        it 'returns all allowed user names' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return('@council,lumbergh,nina')
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return(nil)

          expect(@provider.access).to eq('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])
        end
      end

      context 'when a deny policy is in place' do
        it 'returns all denied user names' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return(nil)
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return('@council,lumbergh,nina')

          expect(@provider.access).to eq('policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'])
        end
      end
    end

    describe '#access=' do
      context "{ 'policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'] }" do
        it 'executes the correct command' do
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-u', 'allow:@council,lumbergh,nina')

          @provider.access = { 'policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'] }
        end
      end

      context "{ 'policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'] }" do
        it 'executes the correct command' do
          expect(@provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-u', 'deny:@council,lumbergh,nina')

          @provider.access = { 'policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'] }
        end
      end
    end

    describe '#make_and_model=(_value)' do
      context 'when ensuring a printer' do
        it 'calls #create_printer' do
          allow(@provider).to receive(:ensure).and_return(:printer)
          expect(@provider).to receive(:create_printer)

          @provider.make_and_model = 'Local Raw Printer'
        end
      end
    end
  end

  describe 'private functions' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office'
      }

      @resource = type.new(manifest)
      @provider = provider.new(@resource)
    end

    describe '#users_is' do
      context 'when no policy is in place' do
        it "returns 'all'" do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return(nil)
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return(nil)

          expect(@provider.send(:users_is)).to eq(%w(all))
        end
      end

      context 'when there are users on an allow policy' do
        it 'returns a sorted array without duplicates' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return('nina,@council,nina,lumbergh')
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return(nil)

          expect(@provider.send(:users_is)).to eq(%w(@council lumbergh nina))
        end
      end

      context 'when there are users on an deny policy' do
        it 'returns a sorted array without duplicates' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return(nil)
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return('nina,@council,nina,lumbergh')

          expect(@provider.send(:users_is)).to eq(%w(@council lumbergh nina))
        end
      end
    end

    describe '#users_should' do
      context 'when the `access` property was NOT specified' do
        it 'returns an empty array' do
          allow(@resource).to receive(:should).with(:access).and_return(nil)

          expect(@provider.send(:users_should)).to eq([])
        end
      end

      context 'when the `access` property was specified' do
        it 'returns the value for `users`' do
          allow(@resource).to receive(:should).with(:access).and_return('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])

          expect(@provider.send(:users_should)).to eq(['@council', 'lumbergh', 'nina'])
        end
      end
    end

    describe '#users_allowed' do
      context 'when there are NO users on an allow policy' do
        it 'returns nil' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return(nil)

          expect(@provider.send(:users_allowed)).to be nil
        end
      end

      context 'when there are users on an allow policy' do
        it 'returns a sorted array without duplicates' do
          allow(@provider).to receive(:query).with('requesting-user-name-allowed').and_return('nina,@council,nina,lumbergh')

          expect(@provider.send(:users_allowed)).to eq(%w(@council lumbergh nina))
        end
      end
    end

    describe '#users_denied' do
      context 'when there are NO users on a deny policy' do
        it 'returns nil' do
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return(nil)

          expect(@provider.send(:users_denied)).to be nil
        end
      end

      context 'when there are users on a deny policy' do
        it 'returns a sorted array without duplicates' do
          allow(@provider).to receive(:query).with('requesting-user-name-denied').and_return('nina,@council,nina,lumbergh')

          expect(@provider.send(:users_denied)).to eq(%w(@council lumbergh nina))
        end
      end
    end
  end
end
