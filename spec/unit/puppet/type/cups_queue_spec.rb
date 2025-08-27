# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define :autorequire do |prerequisite|
  match do |subject|
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource prerequisite
    catalog.add_resource subject

    requirement = subject.autorequire

    !requirement.empty? && requirement[0].source == prerequisite && requirement[0].target == subject
  end
end

RSpec::Matchers.define :have_documentation do
  match do |subject|
    doc = type.attrclass(subject.to_sym).doc

    doc.is_a?(String) && doc.length > 20
  end
end

RSpec.describe "Type 'cups_queue'" do
  let(:type) { Puppet::Type.type(:cups_queue) }
  let(:minimal_printer) { { name: 'Office', ensure: 'printer' } }
  let(:resource) { type.new(minimal_printer) }

  describe 'dependency relations' do
    context 'when ensuring a class' do
      let(:queue) { type.new(name: 'UpperFloor', ensure: 'class', members: ['BackOffice']) }

      it 'autorequires File[/etc/cups/lpoptions]' do
        file = Puppet::Type.type(:file).new(name: '/etc/cups/lpoptions', path: '/etc/cups/lpoptions')

        expect(queue).to autorequire(file)
      end

      it 'autorequires Service[cups]' do
        service = Puppet::Type.type(:service).new(name: 'cups')

        expect(queue).to autorequire(service)
      end

      it 'autorequires its members' do
        member = type.new(name: 'BackOffice')

        expect(queue).to autorequire(member)
      end
    end

    context 'when ensuring a printer' do
      it 'autorequires File[/etc/cups/lpoptions]' do
        file = Puppet::Type.type(:file).new(name: '/etc/cups/lpoptions', path: '/etc/cups/lpoptions')
        queue = type.new(name: 'Office', ensure: 'printer')

        expect(queue).to autorequire(file)
      end

      it 'autorequires Service[cups]' do
        service = Puppet::Type.type(:service).new(name: 'cups')
        queue = type.new(name: 'Office', ensure: 'printer')

        expect(queue).to autorequire(service)
      end

      it 'autorequires its ppd file' do
        ppd = '/usr/share/ppd/cupsfilters/textonly.ppd'
        queue = type.new(name: 'Office', ensure: 'printer', ppd: ppd)
        file = Puppet::Type.type(:file).new(name: ppd)

        expect(queue).to autorequire(file)
      end

      it 'autorequires its model as File resource' do
        model = 'myprinter.ppd'
        queue = type.new(name: 'Office', ensure: 'printer', model: model)
        file = Puppet::Type.type(:file).new(name: "/usr/share/cups/model/#{model}")

        expect(queue).to autorequire(file)
      end
    end
  end

  describe 'mandatory attributes' do
    context 'when ensuring a class' do
      describe 'with members' do
        describe 'unspecified' do
          let(:manifest) do
            {
              ensure: 'class',
              name: 'GroundFloor'
            }
          end

          it 'fails to create an instance' do
            expect { type.new(manifest) }.to raise_error(%r{member})
          end
        end

        describe 'set to an empty array' do
          let(:manifest) do
            {
              ensure: 'class',
              name: 'GroundFloor',
              members: []
            }
          end

          it 'fails to create an instance' do
            expect { type.new(manifest) }.to raise_error(%r{member})
          end
        end

        describe 'set to a string' do
          let(:manifest) do
            {
              ensure: 'class',
              name: 'GroundFloor',
              members: 'Office'
            }
          end

          it 'is able to create an instance' do
            expect(type.new(manifest)).not_to be_nil
          end
        end

        describe 'set to a non-empty array' do
          let(:manifest) do
            {
              ensure: 'class',
              name: 'GroundFloor',
              members: %w[Office Warehouse]
            }
          end

          it 'is able to create an instance' do
            expect(type.new(manifest)).not_to be_nil
          end
        end
      end
    end

    context 'when ensuring a printer' do
      context 'without providing a printer model or PPD file' do
        let(:manifest) do
          {
            ensure: 'printer',
            name: 'Office'
          }
        end

        it 'is able to create an instance' do
          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'when providing only name and model' do
        let(:manifest) do
          {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd'
          }
        end

        it 'is able to create an instance' do
          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'when providing only name and ppd' do
        let(:manifest) do
          {
            ensure: 'printer',
            name: 'Office',
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }
        end

        it 'is able to create an instance' do
          expect(type.new(manifest)).not_to be_nil
        end
      end
    end

    context 'when ensuring absence' do
      let(:manifest) do
        {
          ensure: 'absent',
          name: 'Office'
        }
      end

      it 'does NOT require any other attributes' do
        expect(type.new(manifest)).not_to be_nil
      end
    end
  end

  describe 'mutually exclusive attributes' do
    context 'when ensuring a printer' do
      context 'when providing model and ppd' do
        let(:manifest) do
          {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd',
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }
        end

        it 'fails to create an instance' do
          expect { type.new(manifest) }.to raise_error(%r{mutually})
        end
      end
    end
  end

  describe 'unsupported parameters' do
    context 'when ensuring a class and providing a model' do
      let(:manifest) do
        {
          ensure: 'class',
          name: 'GroundFloor',
          members: %w[Office Warehouse],
          model: 'drv:///sample.drv/generic.ppd'
        }
      end

      it 'fails to create an instance' do
        expect { type.new(manifest) }.to raise_error(%r{support})
      end
    end

    context 'when ensuring a class and providing a PPD file' do
      let(:manifest) do
        {
          ensure: 'class',
          name: 'GroundFloor',
          members: %w[Office Warehouse],
          ppd: '/usr/share/cups/model/myprinter.ppd'
        }
      end

      it 'fails to create an instance' do
        expect { type.new(manifest) }.to raise_error(%r{support})
      end
    end

    context 'when ensuring a class and when providing `make_and_model`' do
      let(:manifest) do
        {
          ensure: 'class',
          name: 'GroundFloor',
          members: %w[Office Warehouse],
          make_and_model: 'Local Printer Class'
        }
      end

      it 'fails to create an instance' do
        expect { type.new(manifest) }.to raise_error(%r{support})
      end
    end

    context 'when ensuring a class and providing an URI' do
      let(:manifest) do
        {
          ensure: 'class',
          name: 'GroundFloor',
          members: %w[Office Warehouse],
          uri: 'lpd://192.168.2.105/binary_p1'
        }
      end

      it 'fails to create an instance' do
        expect { type.new(manifest) }.to raise_error(%r{support})
      end
    end

    context 'when ensuring a printer and providing members' do
      let(:manifest) do
        {
          ensure: 'printer',
          name: 'GroundFloor',
          model: 'drv:///sample.drv/generic.ppd',
          members: %w[Office Warehouse]
        }
      end

      it 'fails to create an instance' do
        expect { type.new(manifest) }.to raise_error(%r{support})
      end
    end
  end

  describe 'parameter' do
    describe 'model' do
      it { is_expected.to have_documentation }

      it 'accepts a string' do
        manifest = minimal_printer.merge(model: 'This is a string')

        resource = type.new(manifest)

        expect(resource[:model]).to eq('This is a string')
      end
    end

    describe 'name' do
      it { is_expected.to have_documentation }

      it 'accepts a string with international characters, numbers and underscores' do
        manifest = minimal_printer.merge(name: 'RSpec_Test_äöü_абв_Nr1')

        resource = type.new(manifest)

        expect(resource[:name]).to eq('RSpec_Test_äöü_абв_Nr1')
      end

      it 'rejects a string with a SPACE' do
        manifest = minimal_printer.merge(name: 'RSpec Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{SPACE})
      end

      it 'rejects a string with a TAB' do
        manifest = minimal_printer.merge(name: "RSpec\tTest_Printer")

        expect { type.new(manifest) }.to raise_error(%r{TAB})
      end

      it 'rejects a string with a carriage return character' do
        manifest = minimal_printer.merge(name: "RSpec\rTest_Printer")

        expect { type.new(manifest) }.to raise_error(%r{SPACE})
      end

      it 'rejects a string with a newline character' do
        manifest = minimal_printer.merge(name: "RSpec\nTest_Printer")

        expect { type.new(manifest) }.to raise_error(%r{SPACE})
      end

      it 'rejects a string with a SLASH' do
        manifest = minimal_printer.merge(name: 'RSpec/Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{SLASH})
      end

      it 'rejects a string with a BACKSLASH' do
        manifest = minimal_printer.merge(name: 'RSpec\Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{BACK[)]?SLASH})
      end

      it 'rejects a string with a SINGLEQUOTE' do
        manifest = minimal_printer.merge(name: "RSpec'Test_Printer")

        expect { type.new(manifest) }.to raise_error(%r{QUOTE})
      end

      it 'rejects a string with a DOUBLEQUOTE' do
        manifest = minimal_printer.merge(name: 'RSpec"Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{QUOTE})
      end

      it 'rejects a string with a COMMA' do
        manifest = minimal_printer.merge(name: 'RSpec,Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{COMMA})
      end

      it 'rejects a string with a "#"' do
        manifest = minimal_printer.merge(name: 'RSpec#Test_Printer')

        expect { type.new(manifest) }.to raise_error(%r{"#"})
      end
    end

    describe 'ppd' do
      it { is_expected.to have_documentation }

      it 'accepts an absolute UNIX file path' do
        manifest = minimal_printer.merge(ppd: '/usr/share/cups/model/myprinter.ppd')

        resource = type.new(manifest)

        expect(resource[:ppd]).to eq('/usr/share/cups/model/myprinter.ppd')
      end

      it 'rejects a path starting with /etc/cups' do
        manifest = minimal_printer.merge(ppd: '/etc/cups/ppd/myprinter.ppd')

        expect { type.new(manifest) }.to raise_error(%r{/usr/share/cups/model})
      end
    end
  end

  describe 'property' do
    describe 'ensure' do
      it { is_expected.to have_documentation }

      context 'when set to class' do
        let(:resource) { type.new(manifest) }
        let(:provider) { type.provider(:cups).new(resource) }

        before do
          resource.provider = provider
        end

        context 'when the class is absent' do
          let(:manifest) { { name: 'UpperFloor', ensure: 'class', members: ['BackOffice'] } }

          before do
            allow(provider).to receive(:class_exists?).and_return(false)
          end

          it 'creates the class' do
            allow(provider).to receive(:create_class)

            resource.property(:ensure).set_class

            expect(provider).to have_received(:create_class)
          end
        end

        context 'when the class is present' do
          let(:manifest) { { name: 'UpperFloor', ensure: 'class', members: ['BackOffice'] } }

          before do
            allow(provider).to receive(:class_exists?).and_return(true)
          end

          it 'does nothing' do
            allow(provider).to receive(:create_class)

            resource.property(:ensure).set_class

            expect(provider).not_to have_received(:create_class)
          end
        end

        context 'when a printer by the same name is present' do
          let(:manifest) { { name: 'UpperFloor', ensure: 'class', members: ['BackOffice'] } }

          before do
            allow(provider).to receive(:printer_exists?).and_return(true)
          end

          it 'creates the class' do
            allow(provider).to receive(:create_class)

            resource.property(:ensure).set_class

            expect(provider).to have_received(:create_class)
          end
        end
      end

      context 'when set to printer' do
        let(:resource) { type.new(manifest) }
        let(:provider) { type.provider(:cups).new(resource) }

        before do
          resource.provider = provider
        end

        context 'when the printer is absent' do
          let(:manifest) { { name: 'Office', ensure: 'printer' } }

          before do
            allow(provider).to receive(:printer_exists?).and_return(false)
          end

          it 'creates the printer' do
            allow(provider).to receive(:create_printer)

            resource.property(:ensure).set_printer

            expect(provider).to have_received(:create_printer)
          end
        end

        context 'when the printer is present' do
          let(:manifest) { { name: 'Office', ensure: 'printer' } }

          before do
            allow(provider).to receive(:printer_exists?).and_return(true)
          end

          it 'does nothing' do
            allow(provider).to receive(:create_printer)

            resource.property(:ensure).set_printer

            expect(provider).not_to have_received(:create_printer)
          end
        end

        context 'when a class by the same name is present' do
          let(:manifest) { { name: 'Office', ensure: 'printer' } }

          before do
            allow(provider).to receive(:class_exists?).and_return(false)
          end

          it 'creates the printer' do
            allow(provider).to receive(:create_printer)

            resource.property(:ensure).set_printer

            expect(provider).to have_received(:create_printer)
          end
        end
      end

      context 'when set to absent' do
        let(:resource) { type.new(manifest) }
        let(:provider) { type.provider(:cups).new(resource) }

        before do
          resource.provider = provider
        end

        context 'when the printer is absent' do
          let(:manifest) { { name: 'Office', ensure: 'absent' } }

          before do
            allow(provider).to receive(:queue_exists?).and_return(false)
          end

          it 'does nothing' do
            allow(provider).to receive(:destroy)

            resource.property(:ensure).set_absent

            expect(provider).not_to have_received(:destroy)
          end
        end

        context 'when a queue by the same name is present' do
          let(:manifest) { { name: 'Office', ensure: 'absent' } }

          before do
            allow(provider).to receive(:queue_exists?).and_return(true)
          end

          it 'removes the queue' do
            allow(provider).to receive(:destroy)

            resource.property(:ensure).set_absent

            expect(provider).to have_received(:destroy)
          end
        end
      end
    end

    describe '#change_to_s' do
      let(:property) { resource.property(:ensure) }

      describe 'from :absent to :class' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :absent, :class)).to eq('created a class')
        end
      end

      describe 'from :absent to :printer' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :absent, :printer)).to eq('created a printer')
        end
      end

      describe 'from :class to :printer' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :class, :printer)).to eq('changed from class to printer')
        end
      end

      describe 'from :printer to :class' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :printer, :class)).to eq('changed from printer to class')
        end
      end

      describe 'from :class to :absent' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :class, :absent)).to eq('class removed')
        end
      end

      describe 'from :printer to :absent' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :printer, :absent)).to eq('printer removed')
        end
      end
    end

    describe 'accepting' do
      it { is_expected.to have_documentation }

      it 'accepts :true' do
        resource[:accepting] = :true
        expect(resource[:accepting]).to eq(:true)
      end

      it 'accepts :false' do
        resource[:accepting] = :false
        expect(resource[:accepting]).to eq(:false)
      end
    end

    describe 'access' do
      it { is_expected.to have_documentation }

      it "accepts { 'policy' => 'allow', 'users' => ['all'] }" do
        resource[:access] = { 'policy' => 'allow', 'users' => ['all'] }
        expect(resource[:access]).to eq('policy' => 'allow', 'users' => ['all'])
      end

      it "accepts { 'policy' => 'deny', 'users' => ['all'] }" do
        resource[:access] = { 'policy' => 'deny', 'users' => ['all'] }
        expect(resource[:access]).to eq('policy' => 'deny', 'users' => ['all'])
      end

      it "accepts an array for key 'users', sorts it, and removes duplicates" do
        resource[:access] = { 'policy' => 'allow', 'users' => ['nina', '@council', 'nina', 'lumbergh'] }
        expect(resource[:access]).to eq('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])
      end

      it 'rejects an array' do
        expect { resource[:access] = %w[a b] }.to raise_error(Puppet::ResourceError)
      end

      it 'rejects a string' do
        expect { resource[:access] = 'This is a string' }.to raise_error(Puppet::ResourceError)
      end

      it 'rejects an empty hash' do
        expect { resource[:access] = {} }.to raise_error(Puppet::ResourceError)
      end

      it 'rejects a hash with unsupported policy' do
        expect { resource[:access] = { 'policy' => 'random', 'users' => ['lumbergh'] } }.to raise_error(Puppet::ResourceError, %r{unsupported})
      end

      it 'rejects a hash with empty users array' do
        expect { resource[:access] = { 'policy' => 'allow', 'users' => [] } }.to raise_error(Puppet::ResourceError, %r{non-empty})
      end

      it 'rejects user names with spaces' do
        expect { resource[:access] = { 'policy' => 'allow', 'users' => ['@coun cil'] } }.to raise_error(Puppet::ResourceError, %r{malformed})
      end

      it 'rejects user names with commas' do
        expect { resource[:access] = { 'policy' => 'allow', 'users' => ['@coun,cil'] } }.to raise_error(Puppet::ResourceError, %r{malformed})
      end
    end

    describe 'description' do
      it { is_expected.to have_documentation }

      it 'accepts a string' do
        resource[:description] = 'This is a string'
        expect(resource[:description]).to eq('This is a string')
      end
    end

    describe 'enabled' do
      it { is_expected.to have_documentation }

      it 'accepts :true' do
        resource[:enabled] = :true
        expect(resource[:enabled]).to eq(:true)
      end

      it 'accepts :false' do
        resource[:enabled] = :false
        expect(resource[:enabled]).to eq(:false)
      end
    end

    describe 'held' do
      it { is_expected.to have_documentation }

      it 'accepts :true' do
        resource[:held] = :true
        expect(resource[:held]).to eq(:true)
      end

      it 'accepts :false' do
        resource[:held] = :false
        expect(resource[:held]).to eq(:false)
      end
    end

    describe 'location' do
      it { is_expected.to have_documentation }

      it 'accepts a string' do
        resource[:location] = 'This is a string'
        expect(resource[:location]).to eq('This is a string')
      end
    end

    describe 'make_and_model' do
      it { is_expected.to have_documentation }

      it 'accepts a string' do
        resource[:make_and_model] = 'This is a string'
        expect(resource[:make_and_model]).to eq('This is a string')
      end
    end

    describe 'members' do
      it { is_expected.to have_documentation }
    end

    describe 'options' do
      it { is_expected.to have_documentation }

      it 'accepts an empty hash' do
        resource[:options] = {}
        expect(resource[:options]).to eq({})
      end

      it 'accepts a typical options hash' do
        resource[:options] = { Duplex: 'DuplexNoTumble', PageSize: 'A4' }
        expect(resource[:options]).to eq(Duplex: 'DuplexNoTumble', PageSize: 'A4')
      end

      it 'rejects an array' do
        expect { resource[:options] = %w[a b] }.to raise_error(Puppet::ResourceError)
      end

      it 'rejects a string' do
        expect { resource[:options] = 'This is a string' }.to raise_error(Puppet::ResourceError)
      end

      it 'rejects a hash containing options already managed by other attributes' do
        %w[printer-is-accepting-jobs printer-info printer-state printer-location printer-is-shared device-uri].each do |key|
          expect { resource[:options] = { key => 'some value' } }.to raise_error(Puppet::ResourceError)
        end
      end

      describe '#is_to_s' do
        it 'returns the options, sorted alphabetically by key' do
          options_is = { 'PageSize' => 'Letter', 'Duplex' => 'None', 'InputSlot' => 'Tray1' }
          expected = '{"Duplex"=>"None", "InputSlot"=>"Tray1", "PageSize"=>"Letter"}'

          resource[:options] = options_is

          expect(resource.property(:options).send(:is_to_s, options_is)).to eq(expected)
        end
      end

      describe '#should_to_s' do
        it 'returns the options, sorted alphabetically by key' do
          options_should = { 'PageSize' => 'A4', 'Duplex' => 'DuplexNoTumble', 'InputSlot' => 'Default' }
          expected = '{"Duplex"=>"DuplexNoTumble", "InputSlot"=>"Default", "PageSize"=>"A4"}'

          resource[:options] = { 'PageSize' => 'Letter', 'Duplex' => 'None', 'InputSlot' => 'Tray1' }

          expect(resource.property(:options).send(:should_to_s, options_should)).to eq(expected)
        end
      end
    end

    describe 'shared' do
      it { is_expected.to have_documentation }

      it 'accepts :true' do
        resource[:shared] = :true
        expect(resource[:shared]).to eq(:true)
      end

      it 'accepts :false' do
        resource[:shared] = :false
        expect(resource[:shared]).to eq(:false)
      end
    end

    describe 'uri' do
      it { is_expected.to have_documentation }

      it 'accepts a typical absolute UNIX file URI' do
        resource[:uri] = 'file:///dev/printer0'
        expect(resource[:uri]).to eq('file:///dev/printer0')
      end

      it 'accepts a typical IPv4 URI' do
        resource[:uri] = 'http://10.0.0.5:631'
        expect(resource[:uri]).to eq('http://10.0.0.5:631')
      end

      it 'accepts a typical IPv6 URI' do
        resource[:uri] = 'http://[2001:7f8::00d1:0:1]:631'
        expect(resource[:uri]).to eq('http://[2001:7f8::00d1:0:1]:631')
      end

      it 'accepts a typical HTTP URI' do
        resource[:uri] = 'http://hostname:631/ipp/port1'
        expect(resource[:uri]).to eq('http://hostname:631/ipp/port1')
      end

      it 'accepts a typical IPP URI' do
        resource[:uri] = 'ipp://hostname/ipp/port1'
        expect(resource[:uri]).to eq('ipp://hostname/ipp/port1')
      end

      it 'accepts a typical LPD URI' do
        resource[:uri] = 'lpd://hostname/queue'
        expect(resource[:uri]).to eq('lpd://hostname/queue')
      end

      it 'accepts a typical HP JetSocket URI' do
        resource[:uri] = 'socket://hostname:9100'
        expect(resource[:uri]).to eq('socket://hostname:9100')
      end
    end
  end
end
