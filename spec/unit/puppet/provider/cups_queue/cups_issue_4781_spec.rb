# encoding: UTF-8
require 'spec_helper'

describe Puppet::Type.type(:cups_queue).provider(:cups) do
  let(:type) { Puppet::Type.type(:cups_queue) }
  let(:provider) { described_class }

  describe '#while_root_allowed' do
    context 'when `access` is NOT specified' do
      before(:each) do
        manifest = {
          ensure: 'printer',
          name: 'Office'
        }

        @resource = type.new(manifest)
        @provider = provider.new(@resource)
      end

      it 'temporarily allows root access, then reinstates the original ACL' do
        acl = { 'policy' => 'allow', 'users' => %w(lumbergh nina) }

        allow(@provider).to receive(:access).and_return(acl)

        expect(@provider).to receive(:access=).with('policy' => 'allow', 'users' => ['root'])
        expect(@provider).to receive(:cupsenable)
        expect(@provider).to receive(:access=).with(acl)

        @provider.enabled = :true
      end
    end

    context 'when `access` was specified' do
      before(:each) do
        manifest = {
          ensure: 'printer',
          name: 'Office',
          access: { 'policy' => 'allow', 'users' => %w(lumbergh nina) }
        }

        @resource = type.new(manifest)
        @provider = provider.new(@resource)
      end

      it 'temporarily allows root access, then sets the desired ACL' do
        allow(@provider).to receive(:access).and_return('policy' => 'allow', 'users' => ['@council'])

        expect(@provider).to receive(:access=).with('policy' => 'allow', 'users' => ['root'])
        expect(@provider).to receive(:cupsenable)
        expect(@provider).to receive(:access=).with('policy' => 'allow', 'users' => %w(lumbergh nina))

        @provider.enabled = :true
      end
    end
  end
end
