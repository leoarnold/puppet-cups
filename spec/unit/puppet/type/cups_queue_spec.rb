# encoding: UTF-8
require 'spec_helper'

describe Puppet::Type.type(:cups_queue) do
  let(:type) { described_class }

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
          it 'should be able to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: 'Office'
            }

            expect(type.new(manifest)).not_to be_nil
          end
        end

        context 'set to a non-empty array' do
          it 'should be able to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: %w(Office Warehouse)
            }

            expect(type.new(manifest)).not_to be_nil
          end
        end
      end
    end

    context 'when ensuring a printer' do
      context 'without providing a printer model, PPD file or a System V interface' do
        it 'should be able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'providing only name and model' do
        it 'should be able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'providing only name and ppd' do
        it 'should be able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end

      context 'providing only name and interface' do
        it 'should be able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            interface: '/usr/share/cups/model/myprinter.sh'
          }

          expect(type.new(manifest)).not_to be_nil
        end
      end
    end

    context 'when ensuring absence' do
      it 'should NOT require any other attributes' do
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

      context 'providing model and interface' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd',
            interface: '/usr/share/cups/model/myprinter.sh'
          }

          expect { type.new(manifest) }.to raise_error(/mutually/)
        end
      end

      context 'providing ppd and interface' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            ppd: '/usr/share/cups/model/myprinter.ppd',
            interface: '/usr/share/cups/model/myprinter.sh'
          }

          expect { type.new(manifest) }.to raise_error(/mutually/)
        end
      end

      context 'providing model, ppd, and interface' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd',
            ppd: '/usr/share/cups/model/myprinter.ppd',
            interface: '/usr/share/cups/model/myprinter.sh'
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
            members: %w(Office Warehouse),
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
            members: %w(Office Warehouse),
            ppd: '/usr/share/cups/model/myprinter.ppd'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end

      context 'providing a System V interface script' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w(Office Warehouse),
            interface: '/usr/share/cups/model/myprinter.sh'
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end

      context 'providing `make_and_model`' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'class',
            name: 'GroundFloor',
            members: %w(Office Warehouse),
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
            members: %w(Office Warehouse),
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
            members: %w(Office Warehouse)
          }

          expect { type.new(manifest) }.to raise_error(/support/)
        end
      end
    end
  end

  describe 'parameter' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/generic.ppd'
      }

      @resource = type.new(manifest)
    end

    describe 'interface' do
      it 'should have documentation' do
        expect(type.attrclass(:interface).doc).to be_instance_of(String)
        expect(type.attrclass(:interface).doc.length).to be > 20
      end

      it 'should accept an absolute UNIX file path' do
        @resource[:interface] = '/usr/share/cups/model/myprinter.sh'
        expect(@resource[:interface]).to eq('/usr/share/cups/model/myprinter.sh')
      end
    end

    describe 'model' do
      it 'should have documentation' do
        expect(type.attrclass(:model).doc).to be_instance_of(String)
        expect(type.attrclass(:model).doc.length).to be > 20
      end

      it 'should accept a string' do
        @resource[:model] = 'This is a string'
        expect(@resource[:model]).to eq('This is a string')
      end
    end

    describe 'name' do
      it 'should have documentation' do
        expect(type.attrclass(:name).doc).to be_instance_of(String)
        expect(type.attrclass(:name).doc.length).to be > 20
      end

      describe 'should accept' do
        it 'a string with international characters, numbers and underscores' do
          @resource[:name] = 'RSpec_Test_äöü_абв_Nr1'
          expect(@resource[:name]).to eq('RSpec_Test_äöü_абв_Nr1')
        end
      end

      describe 'should NOT accept' do
        it 'a string with spaces' do
          expect { @resource[:name] = 'RSpec Test_Printer' }.to raise_error(/may NOT contain/)
        end

        it 'a string with tabs' do
          expect { @resource[:name] = "RSpec\tTest_Printer" }.to raise_error(/may NOT contain/)
        end

        it 'a string with newline characters' do
          expect { @resource[:name] = "RSpec\rTest\nPrinter" }.to raise_error(/may NOT contain/)
        end

        it "a string with a '/'" do
          expect { @resource[:name] = 'RSpec/Test_Printer' }.to raise_error(/may NOT contain/)
        end

        it "a string with a '#'" do
          expect { @resource[:name] = 'RSpec#Test_Printer' }.to raise_error(/may NOT contain/)
        end
      end
    end

    describe 'ppd' do
      it 'should have documentation' do
        expect(type.attrclass(:ppd).doc).to be_instance_of(String)
        expect(type.attrclass(:ppd).doc.length).to be > 20
      end

      it 'should accept an absolute UNIX file path' do
        @resource[:ppd] = '/usr/share/cups/model/myprinter.ppd'
        expect(@resource[:ppd]).to eq('/usr/share/cups/model/myprinter.ppd')
      end
    end
  end

  describe 'property' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/generic.ppd'
      }

      @resource = type.new(manifest)
    end

    describe 'ensure' do
      it 'should have documentation' do
        expect(type.attrclass(:ensure).doc).to be_instance_of(String)
        expect(type.attrclass(:ensure).doc.length).to be > 20
      end

      describe 'should accept the value' do
        it 'class' do
          @resource[:ensure] = 'class'
          expect(@resource[:ensure]).to eq(:class)
        end

        it 'printer' do
          @resource[:ensure] = 'printer'
          expect(@resource[:ensure]).to eq(:printer)
        end

        it 'absent' do
          @resource[:ensure] = 'absent'
          expect(@resource[:ensure]).to eq(:absent)
        end
      end
    end

    describe 'accepting' do
      it 'should have documentation' do
        expect(type.attrclass(:accepting).doc).to be_instance_of(String)
        expect(type.attrclass(:accepting).doc.length).to be > 20
      end

      it 'should accept boolean values' do
        @resource[:accepting] = :true
        expect(@resource[:accepting]).to eq(:true)
        @resource[:accepting] = :false
        expect(@resource[:accepting]).to eq(:false)
      end
    end

    describe 'access' do
      it 'should have documentation' do
        expect(type.attrclass(:access).doc).to be_instance_of(String)
        expect(type.attrclass(:access).doc.length).to be > 20
      end

      describe 'should accept' do
        it 'policy => allow' do
          @resource[:access] = { 'policy' => 'allow', 'users' => ['all'] }
          expect(@resource[:access]).to eq('policy' => 'allow', 'users' => ['all'])
        end

        it 'policy => deny' do
          @resource[:access] = { 'policy' => 'deny', 'users' => ['all'] }
          expect(@resource[:access]).to eq('policy' => 'deny', 'users' => ['all'])
        end

        it 'a `users` array, should sort it, and should remove duplicates' do
          @resource[:access] = { 'policy' => 'allow', 'users' => ['nina', '@council', 'nina', 'lumbergh'] }
          expect(@resource[:access]).to eq('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])
        end
      end

      describe 'should NOT accept' do
        it 'an array' do
          expect { @resource[:access] = %w(a b) }.to raise_error(Puppet::ResourceError)
        end

        it 'a string' do
          expect { @resource[:access] = 'This is a string' }.to raise_error(Puppet::ResourceError)
        end

        it 'an empty hash' do
          expect { @resource[:access] = {} }.to raise_error(Puppet::ResourceError)
        end

        it 'a hash with unsupported policy' do
          expect { @resource[:access] = { 'policy' => 'random', 'users' => ['lumbergh'] } }.to raise_error(Puppet::ResourceError, /unsupported/)
        end

        it 'a hash with empty users array' do
          expect { @resource[:access] = { 'policy' => 'allow', 'users' => [] } }.to raise_error(Puppet::ResourceError, /non-empty/)
        end

        it 'a hash with malformed user names' do
          expect { @resource[:access] = { 'policy' => 'allow', 'users' => ['@coun cil'] } }.to raise_error(Puppet::ResourceError, /malformed/)
          expect { @resource[:access] = { 'policy' => 'allow', 'users' => ['@coun,cil'] } }.to raise_error(Puppet::ResourceError, /malformed/)
        end
      end
    end

    describe 'description' do
      it 'should have documentation' do
        expect(type.attrclass(:description).doc).to be_instance_of(String)
        expect(type.attrclass(:description).doc.length).to be > 20
      end

      it 'should accept a string' do
        @resource[:description] = 'This is a string'
        expect(@resource[:description]).to eq('This is a string')
      end
    end

    describe 'enabled' do
      it 'should have documentation' do
        expect(type.attrclass(:enabled).doc).to be_instance_of(String)
        expect(type.attrclass(:enabled).doc.length).to be > 20
      end

      it 'should accept boolean values' do
        @resource[:enabled] = :true
        expect(@resource[:enabled]).to eq(:true)
        @resource[:enabled] = :false
        expect(@resource[:enabled]).to eq(:false)
      end
    end

    describe 'held' do
      it 'should have documentation' do
        expect(type.attrclass(:held).doc).to be_instance_of(String)
        expect(type.attrclass(:held).doc.length).to be > 20
      end

      it 'should accept boolean values' do
        @resource[:held] = :true
        expect(@resource[:held]).to eq(:true)
        @resource[:held] = :false
        expect(@resource[:held]).to eq(:false)
      end
    end

    describe 'location' do
      it 'should have documentation' do
        expect(type.attrclass(:location).doc).to be_instance_of(String)
        expect(type.attrclass(:location).doc.length).to be > 20
      end

      it 'should accept a string' do
        @resource[:location] = 'This is a string'
        expect(@resource[:location]).to eq('This is a string')
      end
    end

    describe 'make_and_model' do
      it 'should have documentation' do
        expect(type.attrclass(:make_and_model).doc).to be_instance_of(String)
        expect(type.attrclass(:make_and_model).doc.length).to be > 20
      end

      it 'should accept a string' do
        @resource[:make_and_model] = 'This is a string'
        expect(@resource[:make_and_model]).to eq('This is a string')
      end
    end

    describe 'members' do
      it 'should have documentation' do
        expect(type.attrclass(:members).doc).to be_instance_of(String)
        expect(type.attrclass(:members).doc.length).to be > 20
      end
    end

    describe 'options' do
      it 'should have documentation' do
        expect(type.attrclass(:options).doc).to be_instance_of(String)
        expect(type.attrclass(:options).doc.length).to be > 20
      end

      describe 'should accept' do
        it 'an empty hash' do
          @resource[:options] = {}
          expect(@resource[:options]).to eq({})
        end

        it 'a typical options hash' do
          @resource[:options] = { Duplex: 'DuplexNoTumble', PageSize: 'A4' }
          expect(@resource[:options]).to eq(Duplex: 'DuplexNoTumble', PageSize: 'A4')
        end
      end

      describe 'should NOT accept' do
        it 'an array' do
          expect { @resource[:options] = %w(a b) }.to raise_error(Puppet::ResourceError)
        end

        it 'a string' do
          expect { @resource[:options] = 'This is a string' }.to raise_error(Puppet::ResourceError)
        end

        it 'a hash containing options already managed by other attributes' do
          %w(printer-is-accepting-jobs printer-info printer-state printer-location printer-is-shared device-uri).each do |key|
            expect { @resource[:options] = { key => 'some value' } }.to raise_error(Puppet::ResourceError)
          end
        end
      end
    end

    describe 'shared' do
      it 'should have documentation' do
        expect(type.attrclass(:shared).doc).to be_instance_of(String)
        expect(type.attrclass(:shared).doc.length).to be > 20
      end

      it "defaults to 'false'" do
        resource = type.new(name: 'Office')
        expect(resource[:shared]).to eq(:false)
      end

      it 'should accept boolean values' do
        @resource[:shared] = :true
        expect(@resource[:shared]).to eq(:true)
        @resource[:shared] = :false
        expect(@resource[:shared]).to eq(:false)
      end
    end

    describe 'uri' do
      it 'should have documentation' do
        expect(type.attrclass(:uri).doc).to be_instance_of(String)
        expect(type.attrclass(:uri).doc.length).to be > 20
      end

      describe 'should accept' do
        it 'a typical absolute UNIX file uri' do
          @resource[:uri] = 'file:///dev/printer0'
          expect(@resource[:uri]).to eq('file:///dev/printer0')
        end

        it 'a typical IPv4 URI' do
          @resource[:uri] = 'http://10.0.0.5:631'
          expect(@resource[:uri]).to eq('http://10.0.0.5:631')
        end

        it 'a typical IPv6 URI' do
          @resource[:uri] = 'http://[2001:7f8::00d1:0:1]:631'
          expect(@resource[:uri]).to eq('http://[2001:7f8::00d1:0:1]:631')
        end

        it 'a typical HTTP URI' do
          @resource[:uri] = 'http://hostname:631/ipp/port1'
          expect(@resource[:uri]).to eq('http://hostname:631/ipp/port1')
        end

        it 'a typical IPP URI' do
          @resource[:uri] = 'ipp://hostname/ipp/port1'
          expect(@resource[:uri]).to eq('ipp://hostname/ipp/port1')
        end

        it 'a typical LPD URI' do
          @resource[:uri] = 'lpd://hostname/queue'
          expect(@resource[:uri]).to eq('lpd://hostname/queue')
        end

        it 'a typical HP JetSocket URI' do
          @resource[:uri] = 'socket://hostname:9100'
          expect(@resource[:uri]).to eq('socket://hostname:9100')
        end
      end
    end
  end
end
