# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Provider 'cups' for type 'cups_queue'" do
  let(:cups_queue) { Puppet::Type.type(:cups_queue) }
  let(:cups) { cups_queue.provider(:cups) }

  describe '#while_root_allowed' do
    context "when 'access' is NOT specified" do
      let(:resource) { cups_queue.new(name: 'Office', ensure: 'printer') }
      let(:provider) { cups.new(resource) }

      it 'temporarily allows root access, then reinstates the original ACL' do
        acl = { 'policy' => 'allow', 'users' => %w[lumbergh nina] }

        allow(provider).to receive(:access).and_return(acl)

        expect(provider).to receive(:access=).with('policy' => 'allow', 'users' => ['root'])
        expect(provider).to receive(:cupsenable)
        expect(provider).to receive(:access=).with(acl)

        provider.enabled = :true
      end
    end

    context "when 'access' was specified" do
      let(:resource) { cups_queue.new(ensure: 'printer', name: 'Office', access: { 'policy' => 'allow', 'users' => %w[lumbergh nina] }) }
      let(:provider) { cups.new(resource) }

      it 'temporarily allows root access, then sets the desired ACL' do
        allow(provider).to receive(:access).and_return('policy' => 'allow', 'users' => ['@council'])

        expect(provider).to receive(:access=).with('policy' => 'allow', 'users' => ['root'])
        expect(provider).to receive(:cupsenable)
        expect(provider).to receive(:access=).with('policy' => 'allow', 'users' => %w[lumbergh nina])

        provider.enabled = :true
      end
    end
  end
end
