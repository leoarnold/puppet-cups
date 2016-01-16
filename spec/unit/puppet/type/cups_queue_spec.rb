# encoding: UTF-8
require 'spec_helper'

describe Puppet::Type.type(:cups_queue) do
  let(:type) { described_class }

  describe 'mandatory attributes' do
    context 'when ensuring a class with' do
      describe 'members' do
        context 'unspecified' do
          it 'fails to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor'
            }

            expect { type.new(manifest) }.to raise_error(Puppet::ResourceError)
          end
        end

        context 'set to an empty array' do
          it 'fails to create an instance' do
            manifest = {
              ensure: 'class',
              name: 'GroundFloor',
              members: []
            }

            expect { type.new(manifest) }.to raise_error(Puppet::ResourceError)
          end
        end

        context 'set to is a string' do
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
      context 'without providing a printer model' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office'
          }
          expect { type.new(manifest) }.to raise_error(Puppet::ResourceError)
        end
      end

      context 'without providing a destination URI' do
        it 'fails to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd'
          }
          expect { type.new(manifest) }.to raise_error(Puppet::ResourceError)
        end
      end

      context 'providing name & model & uri' do
        it 'should be able to create an instance' do
          manifest = {
            ensure: 'printer',
            name: 'Office',
            model: 'drv:///sample.drv/generic.ppd',
            uri: 'lpd://192.168.2.105/binary_p1'
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

  describe 'parameter' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/generic.ppd',
        uri: 'lpd://192.168.2.105/binary_p1'
      }

      @resource = type.new(manifest)
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
          expect { @resource[:name] = "RSpec\#Test_Printer" }.to raise_error(/may NOT contain/)
        end
      end
    end
  end

  describe 'property' do
    before(:each) do
      manifest = {
        ensure: 'printer',
        name: 'Office',
        model: 'drv:///sample.drv/generic.ppd',
        uri: 'lpd://192.168.2.105/binary_p1'
      }

      @resource = type.new(manifest)
    end

    describe 'ensure' do
      it 'should have documentation' do
        expect(type.attrclass(:ensure).doc).to be_instance_of(String)
        expect(type.attrclass(:ensure).doc.length).to be > 20
      end

      it "defaults to 'unspecified'" do
        resource = type.new(name: 'Office')
        expect(resource[:ensure]).to eq(:unspecified)
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

        it 'unspecified' do
          @resource[:ensure] = 'unspecified'
          expect(@resource[:ensure]).to eq(:unspecified)
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

    describe 'members' do
      it 'should have documentation' do
        expect(type.attrclass(:members).doc).to be_instance_of(String)
        expect(type.attrclass(:members).doc.length).to be > 20
      end
    end

    describe 'shared' do
      it 'should have documentation' do
        expect(type.attrclass(:shared).doc).to be_instance_of(String)
        expect(type.attrclass(:shared).doc.length).to be > 20
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

      describe 'should NOT accept' do
        let(:resource) { type.new(minimal_example) }

        it "a typical absolute UNIX file path without 'file://'" do
          expect { @resource[:uri] = '/dev/printer0' }.to raise_error(Puppet::ResourceError, %r{file://})
        end

        it 'an URI without protocol' do
          expect { @resource[:uri] = 'hostname:9100' }.to raise_error(Puppet::ResourceError)
        end
      end
    end
  end
end
