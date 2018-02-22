# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Type 'cups_queue'" do
  let(:type) { Puppet::Type.type(:cups_queue) }
  let(:minimal_printer) { { name: 'Office', ensure: 'printer' } }
  let(:resource) { type.new(minimal_printer) }

  describe 'dependency relations' do
    let(:catalog) { Puppet::Resource::Catalog.new }

    context 'when ensuring a class' do
      let(:queue) { type.new(name: 'UpperFloor', ensure: 'class', members: ['BackOffice']) }

      before(:example) { catalog.add_resource queue }

      it 'autorequires File[/etc/cups/lpoptions]' do
        file = Puppet::Type.type(:file).new(name: '/etc/cups/lpoptions', path: '/etc/cups/lpoptions')
        catalog.add_resource file

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(file)
        expect(reqs[0].target).to eq(queue)
      end

      it 'autorequires Service[cups]' do
        service = Puppet::Type.type(:service).new(name: 'cups')
        catalog.add_resource service

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(service)
        expect(reqs[0].target).to eq(queue)
      end

      it 'autorequires its members' do
        member = type.new(name: 'BackOffice')
        catalog.add_resource member

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(member)
        expect(reqs[0].target).to eq(queue)
      end
    end

    context 'when ensuring a printer' do
      it 'autorequires File[/etc/cups/lpoptions]' do
        file = Puppet::Type.type(:file).new(name: '/etc/cups/lpoptions', path: '/etc/cups/lpoptions')
        catalog.add_resource file

        queue = type.new(name: 'Office', ensure: 'printer')
        catalog.add_resource queue

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(file)
        expect(reqs[0].target).to eq(queue)
      end

      it 'autorequires Service[cups]' do
        service = Puppet::Type.type(:service).new(name: 'cups')
        catalog.add_resource service

        queue = type.new(name: 'Office', ensure: 'printer')
        catalog.add_resource queue

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(service)
        expect(reqs[0].target).to eq(queue)
      end

      it 'autorequires its ppd file' do
        ppd = '/usr/share/ppd/cupsfilters/textonly.ppd'

        queue = type.new(name: 'Office', ensure: 'printer', ppd: ppd)
        catalog.add_resource queue

        file = Puppet::Type.type(:file).new(name: ppd)
        catalog.add_resource file

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(file)
        expect(reqs[0].target).to eq(queue)
      end

      it 'autorequires its model as File resource' do
        model = 'myprinter.ppd'

        queue = type.new(name: 'Office', ensure: 'printer', model: model)
        catalog.add_resource queue

        file = Puppet::Type.type(:file).new(name: "/usr/share/cups/model/#{model}")
        catalog.add_resource file

        reqs = queue.autorequire

        expect(reqs).not_to be_empty
        expect(reqs[0].source).to eq(file)
        expect(reqs[0].target).to eq(queue)
      end
    end
  end

  describe 'mandatory attributes' do
    context 'when ensuring a class' do
      describe 'with members' do
        context 'unspecified' do
          it 'fails to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor'
            }

            expect { type.new(manifest) }.to raise_error(/member/)
          end
        end

        context 'set to an empty array' do
          it 'fails to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: []
            }

            expect { type.new(manifest) }.to raise_error(/member/)
          end
        end

        context 'set to a string' do
          it 'is able to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: 'Office'
            }

            expect(type.new(manifest)).not_to be_nil
          end
        end

        context 'set to a non-empty array' do
          it 'is able to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: %w[Office Warehouse]
            }

            expect(type.new(manifest)).not_to be_nil
          end
        end
      end
    end

    context 'when ensuring a printer' do
      context 'without providing a printer model or PPD file' do
        it 'is able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'providing only name and model' do
        it 'is able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'providing only name and ppd' do
        it 'is able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end
    end

    context 'when ensuring absence' do
      it 'does NOT require any other attributes' do
        manifest = {
          ensure: 'absent',
          name: 'Office'
        }

        expect(type.new(manifest)).not_to be_nil
      end
    end
  end

  describe 'mutually exclusive attributes' do
    context 'when ensuring a printer' do
      context 'providing model and ppd' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd',
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }

          expect { type.new(manifest) }.to raise_error(/mutually/)
        end
      end
    end
  end

  describe 'unsupported parameters' do
    context 'when ensuring a class' do
      context 'providing a model' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w[Office Warehouse],
            model: 'drv:///sample.drv/generic.ppd'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end

      context 'providing a PPD file' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w[Office Warehouse],
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end

      context 'providing `make_and_model`' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w[Office Warehouse],
            make_and_model: 'Local Printer Class'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end

      context 'providing an URI' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w[Office Warehouse],
            uri: 'lpd://192.168.2.105/binary_p1'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end
    end

    context 'ensuring a printer' do
      context 'providing members' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'GroundFloor',
            model: 'drv:///sample.drv/generic.ppd',
            members: %w[Office Warehouse]
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end
    end
  end

  describe 'parameter' do
    describe 'model' do
      it 'has documentation' do
        expect(type.attrclass(:model).doc).to be_instance_of(String)
        expect(type.attrclass(:model).doc.length).to be > 20
      end

      it 'accepts a string' do
        manifest = minimal_printer.merge(model: 'This is a string')

        resource = type.new(manifest)

        expect(resource[:model]).to eq('This is a string')
      end
    end

    describe 'name' do
      it 'has documentation' do
        expect(type.attrclass(:name).doc).to be_instance_of(String)
        expect(type.attrclass(:name).doc.length).to be > 20
      end

      it 'accepts a string with international characters, numbers and underscores' do
        manifest = minimal_printer.merge(name: 'RSpec_Test_äöü_абв_Nr1')

        resource = type.new(manifest)

        expect(resource[:name]).to eq('RSpec_Test_äöü_абв_Nr1')
      end

      it 'rejects a string with a SPACE' do
        manifest = minimal_printer.merge(name: 'RSpec Test_Printer')

        expect { type.new(manifest) }.to raise_error(/SPACE/)
      end

      it 'rejects a string with a TAB' do
        manifest = minimal_printer.merge(name: "RSpec\tTest_Printer")

        expect { type.new(manifest) }.to raise_error(/TAB/)
      end

      it 'rejects a string with a carriage return character' do
        manifest = minimal_printer.merge(name: "RSpec\rTest_Printer")

        expect { type.new(manifest) }.to raise_error(/SPACE/)
      end

      it 'rejects a string with a newline character' do
        manifest = minimal_printer.merge(name: "RSpec\nTest_Printer")

        expect { type.new(manifest) }.to raise_error(/SPACE/)
      end

      it 'rejects a string with a SLASH' do
        manifest = minimal_printer.merge(name: 'RSpec/Test_Printer')

        expect { type.new(manifest) }.to raise_error(/SLASH/)
      end

      it 'rejects a string with a BACKSLASH' do
        manifest = minimal_printer.merge(name: 'RSpec\Test_Printer')

        expect { type.new(manifest) }.to raise_error(/BACK[)]?SLASH/)
      end

      it 'rejects a string with a SINGLEQUOTE' do
        manifest = minimal_printer.merge(name: "RSpec'Test_Printer")

        expect { type.new(manifest) }.to raise_error(/QUOTE/)
      end

      it 'rejects a string with a DOUBLEQUOTE' do
        manifest = minimal_printer.merge(name: 'RSpec"Test_Printer')

        expect { type.new(manifest) }.to raise_error(/QUOTE/)
      end

      it 'rejects a string with a COMMA' do
        manifest = minimal_printer.merge(name: 'RSpec,Test_Printer')

        expect { type.new(manifest) }.to raise_error(/COMMA/)
      end

      it 'rejects a string with a "#"' do
        manifest = minimal_printer.merge(name: 'RSpec#Test_Printer')

        expect { type.new(manifest) }.to raise_error(/"#"/)
      end
    end

    describe 'ppd' do
      it 'has documentation' do
        expect(type.attrclass(:ppd).doc).to be_instance_of(String)
        expect(type.attrclass(:ppd).doc.length).to be > 20
      end

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
      it 'has documentation' do
        expect(type.attrclass(:ensure).doc).to be_instance_of(String)
        expect(type.attrclass(:ensure).doc.length).to be > 20
      end

      context '=> class' do
        context 'when the class is absent' do
          it 'creates the class' do
            resource = type.new(name: 'UpperFloor', ensure: 'class', members: ['BackOffice'])
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:class_exists?).and_return(false)
            expect(resource.provider).to receive(:create_class)

            resource.property(:ensure).set_class
          end
        end

        context 'when the class is present' do
          it 'does nothing' do
            resource = type.new(name: 'UpperFloor', ensure: 'class', members: ['BackOffice'])
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:class_exists?).and_return(true)
            expect(resource.provider).not_to receive(:create_class)

            resource.property(:ensure).set_class
          end
        end

        context 'when a printer by the same name is present' do
          it 'creates the class' do
            resource = type.new(name: 'UpperFloor', ensure: 'class', members: ['BackOffice'])
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:class_exists?).and_return(false)
            expect(resource.provider).to receive(:create_class)

            resource.property(:ensure).set_class
          end
        end
      end

      context '=> printer' do
        context 'when the printer is absent' do
          it 'creates the printer' do
            resource = type.new(name: 'Office', ensure: 'printer')
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:printer_exists?).and_return(false)
            expect(resource.provider).to receive(:create_printer)

            resource.property(:ensure).set_printer
          end
        end

        context 'when the printer is present' do
          it 'does nothing' do
            resource = type.new(name: 'Office', ensure: 'printer')
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:printer_exists?).and_return(true)
            expect(resource.provider).not_to receive(:create_printer)

            resource.property(:ensure).set_printer
          end
        end

        context 'when a class by the same name is present' do
          it 'creates the printer' do
            resource = type.new(name: 'Office', ensure: 'printer')
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:printer_exists?).and_return(false)
            expect(resource.provider).to receive(:create_printer)

            resource.property(:ensure).set_printer
          end
        end
      end

      context '=> absent' do
        context 'when the printer is absent' do
          it 'does nothing' do
            resource = type.new(name: 'Office', ensure: 'absent')
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:queue_exists?).and_return(false)
            expect(resource.provider).not_to receive(:destroy)

            resource.property(:ensure).set_absent
          end
        end

        context 'when a queue by the same name is present' do
          it 'removes the queue' do
            resource = type.new(name: 'Office', ensure: 'absent')
            resource.provider = type.provider(:cups).new(resource)

            expect(resource.provider).to receive(:queue_exists?).and_return(true)
            expect(resource.provider).to receive(:destroy)

            resource.property(:ensure).set_absent
          end
        end
      end
    end

    describe '#change_to_s' do
      let(:property) { resource.property(:ensure) }

      context 'narrates the change' do
        it 'mentions the creation of a class' do
          expect(property.send(:change_to_s, :absent, :class)).to eq('created a class')
        end
      end

      context 'from :absent to :printer' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :absent, :printer)).to eq('created a printer')
        end
      end

      context 'from :class to :printer' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :class, :printer)).to eq('changed from class to printer')
        end
      end

      context 'from :printer to :class' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :printer, :class)).to eq('changed from printer to class')
        end
      end

      context 'from :class to :absent' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :class, :absent)).to eq('class removed')
        end
      end

      context 'from :printer to :class' do
        it 'narrates the change' do
          expect(property.send(:change_to_s, :printer, :absent)).to eq('printer removed')
        end
      end
    end

    describe 'accepting' do
      it 'has documentation' do
        expect(type.attrclass(:accepting).doc).to be_instance_of(String)
        expect(type.attrclass(:accepting).doc.length).to be > 20
      end

      it 'accepts boolean values' do
        resource[:accepting] = :true
        expect(resource[:accepting]).to eq(:true)

        resource[:accepting] = :false
        expect(resource[:accepting]).to eq(:false)
      end
    end

    describe 'access' do
      it 'has documentation' do
        expect(type.attrclass(:access).doc).to be_instance_of(String)
        expect(type.attrclass(:access).doc.length).to be > 20
      end

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
        expect { resource[:access] = { 'policy' => 'random', 'users' => ['lumbergh'] } }.to raise_error(Puppet::ResourceError, /unsupported/)
      end

      it 'rejects a hash with empty users array' do
        expect { resource[:access] = { 'policy' => 'allow', 'users' => [] } }.to raise_error(Puppet::ResourceError, /non-empty/)
      end

      it 'rejects a hash with malformed user names' do
        expect { resource[:access] = { 'policy' => 'allow', 'users' => ['@coun cil'] } }.to raise_error(Puppet::ResourceError, /malformed/)
        expect { resource[:access] = { 'policy' => 'allow', 'users' => ['@coun,cil'] } }.to raise_error(Puppet::ResourceError, /malformed/)
      end
    end

    describe 'description' do
      it 'has documentation' do
        expect(type.attrclass(:description).doc).to be_instance_of(String)
        expect(type.attrclass(:description).doc.length).to be > 20
      end

      it 'accepts a string' do
        resource[:description] = 'This is a string'
        expect(resource[:description]).to eq('This is a string')
      end
    end

    describe 'enabled' do
      it 'has documentation' do
        expect(type.attrclass(:enabled).doc).to be_instance_of(String)
        expect(type.attrclass(:enabled).doc.length).to be > 20
      end

      it 'accepts boolean values' do
        resource[:enabled] = :true
        expect(resource[:enabled]).to eq(:true)
        resource[:enabled] = :false
        expect(resource[:enabled]).to eq(:false)
      end
    end

    describe 'held' do
      it 'has documentation' do
        expect(type.attrclass(:held).doc).to be_instance_of(String)
        expect(type.attrclass(:held).doc.length).to be > 20
      end

      it 'accepts boolean values' do
        resource[:held] = :true
        expect(resource[:held]).to eq(:true)
        resource[:held] = :false
        expect(resource[:held]).to eq(:false)
      end
    end

    describe 'location' do
      it 'has documentation' do
        expect(type.attrclass(:location).doc).to be_instance_of(String)
        expect(type.attrclass(:location).doc.length).to be > 20
      end

      it 'accepts a string' do
        resource[:location] = 'This is a string'
        expect(resource[:location]).to eq('This is a string')
      end
    end

    describe 'make_and_model' do
      it 'has documentation' do
        expect(type.attrclass(:make_and_model).doc).to be_instance_of(String)
        expect(type.attrclass(:make_and_model).doc.length).to be > 20
      end

      it 'accepts a string' do
        resource[:make_and_model] = 'This is a string'
        expect(resource[:make_and_model]).to eq('This is a string')
      end
    end

    describe 'members' do
      it 'has documentation' do
        expect(type.attrclass(:members).doc).to be_instance_of(String)
        expect(type.attrclass(:members).doc.length).to be > 20
      end
    end

    describe 'options' do
      it 'has documentation' do
        expect(type.attrclass(:options).doc).to be_instance_of(String)
        expect(type.attrclass(:options).doc.length).to be > 20
      end

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
          expectation = '{"Duplex"=>"None", "InputSlot"=>"Tray1", "PageSize"=>"Letter"}'

          resource[:options] = options_is

          expect(resource.property(:options).send(:is_to_s, options_is)).to eq(expectation)
        end
      end

      describe '#should_to_s' do
        it 'returns the options, sorted alphabetically by key' do
          options_should = { 'PageSize' => 'A4', 'Duplex' => 'DuplexNoTumble', 'InputSlot' => 'Default' }
          expectation = '{"Duplex"=>"DuplexNoTumble", "InputSlot"=>"Default", "PageSize"=>"A4"}'

          resource[:options] = { 'PageSize' => 'Letter', 'Duplex' => 'None', 'InputSlot' => 'Tray1' }

          expect(resource.property(:options).send(:should_to_s, options_should)).to eq(expectation)
        end
      end
    end

    describe 'shared' do
      it 'has documentation' do
        expect(type.attrclass(:shared).doc).to be_instance_of(String)
        expect(type.attrclass(:shared).doc.length).to be > 20
      end

      it 'accepts boolean values' do
        resource[:shared] = :true
        expect(resource[:shared]).to eq(:true)
        resource[:shared] = :false
        expect(resource[:shared]).to eq(:false)
      end
    end

    describe 'uri' do
      it 'has documentation' do
        expect(type.attrclass(:uri).doc).to be_instance_of(String)
        expect(type.attrclass(:uri).doc.length).to be > 20
      end

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
