# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Provider 'cups' for type 'cups_queue'" do
  let(:cups_queue) { Puppet::Type.type(:cups_queue) }
  let(:cups) { cups_queue.provider(:cups) }

  describe '#while_root_allowed' do
    context "when 'access' is NOT specified" do
      let(:resource) { cups_queue.new(name: 'Office', ensure: 'printer') }
      let(:provider) { cups.new(resource) }
      let(:acl) { { 'policy' => 'allow', 'users' => %w[lumbergh nina] } }

      before do
        allow(provider).to receive(:access).and_return(acl)
        allow(provider).to receive(:access=)
        allow(provider).to receive(:cupsenable)
      end

      it 'temporarily allows root access' do
        provider.enabled = :true

        expect(provider).to have_received(:access=).with('policy' => 'allow', 'users' => ['root'])
      end

      it 'enables the queue' do
        provider.enabled = :true

        expect(provider).to have_received(:cupsenable)
      end

      it 'reinstates the acl from before' do
        provider.enabled = :true

        expect(provider).to have_received(:access=).with(acl)
      end
    end

    context "when 'access' was specified" do
      let(:resource) { cups_queue.new(ensure: 'printer', name: 'Office', access: { 'policy' => 'allow', 'users' => %w[lumbergh nina] }) }
      let(:provider) { cups.new(resource) }

      before do
        allow(provider).to receive(:access).and_return('policy' => 'allow', 'users' => ['@council'])
        allow(provider).to receive(:access=)
        allow(provider).to receive(:cupsenable)
      end

      it 'temporarily allows root access' do
        provider.enabled = :true

        expect(provider).to have_received(:access=).with('policy' => 'allow', 'users' => ['root'])
      end

      it 'enables the queue' do
        provider.enabled = :true

        expect(provider).to have_received(:cupsenable)
      end

      it 'sets the acl specified' do
        provider.enabled = :true

        expect(provider).to have_received(:access=).with('policy' => 'allow', 'users' => %w[lumbergh nina])
      end
    end
  end
end
