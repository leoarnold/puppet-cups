# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Provider 'cups' for type 'cups_queue'" do
  let(:cups_queue) { Puppet::Type.type(:cups_queue) }
  let(:cups) { cups_queue.provider(:cups) }

  describe 'static class method' do
    describe '#instances' do
      shared_examples 'correct instances' do |classmembers, printers|
        it 'returns the correct array of provider instances' do
          allow(PuppetX::Cups::Instances).to receive(:classmembers).and_return(classmembers)
          allow(PuppetX::Cups::Instances).to receive(:printers).and_return(printers)

          instances = cups.instances
          instance = nil

          printers.each do |name|
            instances.delete_if { |i| instance = i if i.name == name }
            expect(instance).to be_a cups
            expect(instance.ensure).to eq(:printer)
          end

          classmembers.each do |name, members|
            instances.delete_if { |i| instance = i if i.name == name }
            expect(instance).to be_a cups
            expect(instance.ensure).to eq(:class)
            expect(instance.members).to eq(members)
          end

          expect(instances).to eq([])
        end
      end

      context 'without printers or classes installed' do
        include_examples 'correct instances', [{}, []]
      end

      context 'with printers, but without classes installed' do
        include_examples 'correct instances', [{}, %w[BackOffice Office Warehouse]]
      end

      context 'with printers and classes installed' do
        include_examples 'correct instances', [{
          'CrawlSpace'  => %w[],
          'GroundFloor' => %w[Office Warehouse],
          'UpperFloor'  => %w[BackOffice]
        }, %w[BackOffice Office Warehouse]]
      end
    end

    describe '#prefetch' do
      shared_examples 'correct prefetch' do |specified, installed|
        it 'adds all discovered provider instance to their resources if specified' do
          instances = []
          resource_hash = {}

          installed.each do |name|
            instances << cups.new(cups_queue.new(name: name, ensure: :printer))
          end

          allow(cups).to receive(:instances).and_return(instances)

          specified.each do |name|
            resource_hash[name] = cups_queue.new(name: name, ensure: :printer)
          end

          cups.prefetch(resource_hash)

          specified.each do |name|
            expect(resource_hash[name].provider).to be_a cups if installed.include? name
          end
        end
      end

      context 'when no queues are installed' do
        include_examples 'correct prefetch', [%w[BackOffice Office Warehouse], %w[]]
      end

      context 'when some specified queues are installed' do
        include_examples 'correct prefetch', [%w[BackOffice Office Warehouse], %w[Office]]
      end

      context 'when more queues are installed than specified' do
        include_examples 'correct prefetch', [%w[Office], %w[BackOffice Office Warehouse]]
      end
    end
  end

  context 'when managing a class' do
    let(:resource) { cups_queue.new(name: 'GroundFloor', ensure: 'class', members: %w[Office Warehouse]) }
    let(:provider) { cups.new(resource) }

    describe '#create_class' do
      context 'using the minimal manifest' do
        it 'installs the class with default values' do
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-c', 'GroundFloor')
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Warehouse', '-c', 'GroundFloor')

          provider.create_class
        end
      end
    end

    describe '#destroy' do
      it 'deletes the class if it exists' do
        allow(provider).to receive(:queue_exists?).and_return(true)
        expect(provider).to receive(:lpadmin).with('-E', '-x', 'GroundFloor')

        provider.destroy
      end
    end
  end

  context 'when managing a printer' do
    shared_examples 'provider contract' do |manifest|
      let(:resource) { cups_queue.new(manifest) }
      let(:provider) { cups.new(resource) }

      describe '#create_printer' do
        it 'installs the printer with default values and checks for correct make_and_model' do
          switch = { model: '-m', ppd: '-P' }
          method = (manifest.keys & switch.keys)[0]

          allow(provider).to receive(:lpadmin).with('-E', '-x', 'Office')
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-v', 'file:///dev/null')
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', switch[method], manifest[method]) if method
          expect(provider).to receive(:check_make_and_model)

          provider.create_printer
        end
      end

      describe '#destroy' do
        it 'deletes the printer if it exists' do
          allow(provider).to receive(:queue_exists?).and_return(true)
          expect(provider).to receive(:lpadmin).with('-E', '-x', 'Office')

          provider.destroy
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
  end

  describe 'provider method' do
    let(:resource) { cups_queue.new(name: 'Office', ensure: 'printer') }
    let(:provider) { cups.new(resource) }

    describe '#accepting' do
      it 'calls #query with the correct parameter' do
        expect(provider).to receive(:query).with('printer-is-accepting-jobs')

        provider.accepting
      end
    end

    describe '#accepting=' do
      context 'true' do
        it 'calls #cupsaccept with the correct arguments' do
          expect(provider).to receive(:cupsaccept).with('-E', 'Office')

          provider.accepting = :true
        end
      end

      context 'false' do
        it 'calls #cupsreject with the correct arguments' do
          expect(provider).to receive(:cupsreject).with('-E', 'Office')

          provider.accepting = :false
        end
      end
    end

    describe '#access' do
      context 'when no policy is in place' do
        it 'returns all users allowed' do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('')

          expect(provider.access).to eq('policy' => 'allow', 'users' => ['all'])
        end
      end

      context 'when an allow policy is in place' do
        it 'returns all allowed user names' do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('@council,lumbergh,nina')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('')

          expect(provider.access).to eq('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])
        end
      end

      context 'when a deny policy is in place' do
        it 'returns all denied user names' do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('@council,lumbergh,nina')

          expect(provider.access).to eq('policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'])
        end
      end
    end

    describe '#access=' do
      context "{ 'policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'] }" do
        it 'executes the correct command' do
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-u', 'allow:@council,lumbergh,nina')

          provider.access = { 'policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'] }
        end
      end

      context "{ 'policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'] }" do
        it 'executes the correct command' do
          expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-u', 'deny:@council,lumbergh,nina')

          provider.access = { 'policy' => 'deny', 'users' => ['@council', 'lumbergh', 'nina'] }
        end
      end
    end

    describe '#description' do
      it 'calls #query with the correct parameter' do
        expect(provider).to receive(:query).with('printer-info').and_return('color / duplex / stapling')

        expect(provider.description).to eq('color / duplex / stapling')
      end
    end

    describe '#description=' do
      it 'calls #lpadmin with the correct arguments' do
        expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-D', 'color / duplex / stapling')

        provider.description = 'color / duplex / stapling'
      end
    end

    describe '#enabled' do
      context 'when the printer is idle' do
        it "returns 'true'" do
          expect(provider).to receive(:query).with('printer-state').and_return('idle')

          expect(provider.enabled).to eq(:true)
        end
      end

      context 'when the printer is processing' do
        it "returns 'true'" do
          expect(provider).to receive(:query).with('printer-state').and_return('processing')

          expect(provider.enabled).to eq(:true)
        end
      end

      context 'when the printer is stopped' do
        it "returns 'false'" do
          expect(provider).to receive(:query).with('printer-state').and_return('stopped')

          expect(provider.enabled).to eq(:false)
        end
      end
    end

    describe '#enabled=' do
      context "'true'" do
        it 'calls #cupsenable with the correct arguments' do
          target_acl = { 'policy' => 'allow', 'users' => %w[lumbergh nina] }
          expect(provider).to receive(:access).and_return(target_acl)
          expect(provider).to receive(:access=).with('policy' => 'allow', 'users' => ['root'])
          expect(provider).to receive(:cupsenable).with('-E', 'Office')
          expect(provider).to receive(:access=).with(target_acl)

          provider.enabled = :true
        end
      end

      context "'false'" do
        it 'calls #cupsdisable with the correct arguments' do
          expect(provider).to receive(:cupsdisable).with('-E', 'Office')

          provider.enabled = :false
        end
      end
    end

    describe '#held' do
      context 'when new jobs are being held' do
        it "returns 'true'" do
          expect(provider).to receive(:query).with('printer-state-reasons').and_return('hold-new-jobs')

          expect(provider.held).to eq(:true)
        end
      end

      context 'when new jobs are NOT being held' do
        it "returns 'false'" do
          expect(provider).to receive(:query).with('printer-state-reasons').and_return('paused')

          expect(provider.held).to eq(:false)
        end
      end
    end

    describe '#held=' do
      context 'true' do
        it 'calls #cupsenable with the correct arguments' do
          expect(provider).to receive(:cupsdisable).with('-E', '--hold', 'Office')

          provider.held = :true
        end
      end

      context 'false' do
        it 'calls #cupsdisable with the correct arguments' do
          expect(provider).to receive(:cupsenable).with('-E', '--release', 'Office')

          provider.held = :false
        end
      end
    end

    describe '#location' do
      it 'calls #query with the correct parameter' do
        expect(provider).to receive(:query).with('printer-location').and_return('Room 101')

        expect(provider.location).to eq('Room 101')
      end
    end

    describe '#location=' do
      it 'calls #lpadmin with the correct arguments' do
        expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-L', 'Room 101')

        provider.location = 'Room 101'
      end
    end

    describe '#make_and_model' do
      context 'when fetching a class' do
        it 'returns nil' do
          allow(provider).to receive(:ensure).and_return(:class)

          expect(provider.make_and_model).to be nil
        end
      end

      context 'when fetching a printer' do
        it 'calls #query with the correct parameter' do
          allow(provider).to receive(:printer_exists?).and_return(true)
          expect(provider).to receive(:query).with('printer-make-and-model').and_return('Local Raw Printer')

          expect(provider.make_and_model).to eq('Local Raw Printer')
        end
      end
    end

    describe '#make_and_model=(_value)' do
      context 'when ensuring a printer' do
        it 'calls #create_printer and #check_make_and_model' do
          expect(provider).to receive(:create_printer)
          expect(provider).to receive(:check_make_and_model)

          provider.make_and_model = 'Local Raw Printer'
        end
      end
    end

    describe '#members=(_value)' do
      context 'when ensuring a class' do
        it 'calls #create_class' do
          allow(provider).to receive(:class_exists?).and_return(true)
          expect(provider).to receive(:create_class)

          provider.members = %w[Office Warehouse]
        end
      end
    end

    describe '#options' do
      context 'when the `options` property is NOT specified' do
        it 'returns a hash of all retrievable options and their current values' do
          current = { 'PageSize' => 'Letter', 'Duplex' => 'None' }

          allow(resource).to receive(:should).with(:options).and_return(nil)
          allow(provider).to receive(:supported_options_is).and_return(current)

          expect(provider.options).to eq(current)
        end
      end

      context 'when the `options` property is specified' do
        it 'fails on unsupported options' do
          current = { 'PageSize' => 'Letter', 'Duplex' => 'None' }
          should = { 'TimeZone' => 'Saturn' }

          allow(resource).to receive(:should).with(:options).and_return(should)
          allow(provider).to receive(:supported_options_is).and_return(current)

          expect { provider.options }.to raise_error(/TimeZone/)
        end

        it 'returns a hash of all specified options and their current values' do
          current = { 'PageSize' => 'Letter', 'Duplex' => 'None' }
          should = { 'PageSize' => 'A4' }
          expected = { 'PageSize' => 'Letter' }

          allow(resource).to receive(:should).with(:options).and_return(should)
          allow(provider).to receive(:supported_options_is).and_return(current)

          expect(provider.options).to eq(expected)
        end
      end

      describe '#options=' do
        context "{ 'PageSize' => 'A4', 'Duplex' => 'None' }" do
          it 'makes the correct calls to `lpadmin`' do
            expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-o', 'PageSize=A4')
            expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-o', 'Duplex=None')
            provider.options = { 'PageSize' => 'A4', 'Duplex' => 'None' }
          end
        end
      end

      describe '#uri' do
        context 'when fetching a class' do
          it 'returns nil' do
            allow(provider).to receive(:class_exists?).and_return(true)

            expect(provider.uri).to be nil
          end
        end
      end
    end

    describe '#shared' do
      it 'calls #query with the correct parameter' do
        expect(provider).to receive(:query).with('printer-is-shared')

        provider.shared
      end
    end

    describe '#shared=' do
      it 'calls #lpadmin with the correct arguments' do
        expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-o', 'printer-is-shared=true')

        provider.shared = :true
      end
    end

    describe '#uri' do
      context 'when fetching a printer' do
        it 'calls #query with the correct parameter' do
          allow(provider).to receive(:printer_exists?).and_return(true)

          expect(provider).to receive(:query).with('device-uri').and_return('file:///dev/null')
          expect(provider.uri).to eq('file:///dev/null')
        end
      end
    end

    describe '#uri=' do
      it 'calls #lpadmin with the correct arguments' do
        expect(provider).to receive(:lpadmin).with('-E', '-p', 'Office', '-v', 'file:///dev/null')

        provider.uri = 'file:///dev/null'
      end
    end
  end

  describe 'private functions' do
    let(:resource) { cups_queue.new(name: 'Office', ensure: 'printer') }
    let(:provider) { cups.new(resource) }

    describe '#query' do
      it 'sends a query to the IPP module' do
        expect(PuppetX::Cups::Queue).to receive(:attribute).with('Office', 'printer-location')

        provider.send(:query, 'printer-location')
      end
    end

    describe '#check_make_and_model' do
      context 'when NO make_and_model was provided' do
        it 'does not raise an error' do
          allow(provider).to receive(:query).with('printer-make-and-model').and_return('Local Raw Printer')

          expect { provider.send(:check_make_and_model) }.not_to raise_error
        end
      end

      context 'when a make_and_model was provided' do
        let(:resource) { cups_queue.new(ensure: 'printer', name: 'Office', make_and_model: 'HP DeskJet 550C') }
        let(:provider) { cups.new(resource) }

        context 'and the `model` / `ppd` was suitable to achieve this make_and_model' do
          it 'does not raise an error' do
            allow(provider).to receive(:query).with('printer-make-and-model').and_return('HP DeskJet 550C')

            expect { provider.send(:check_make_and_model) }.not_to raise_error
          end
        end

        context 'and the `model` / `ppd` did NOT yield this make_and_model' do
          it 'does not raise an error' do
            allow(provider).to receive(:query).with('printer-make-and-model').and_return('Local Raw Printer')

            expect { provider.send(:check_make_and_model) }.to raise_error(/make_and_model/)
          end
        end
      end
    end

    describe '#specified_options_is' do
      it 'fails on unsupported options' do
        current = { 'PageSize' => 'Letter', 'Duplex' => 'None' }
        should = { 'TimeZone' => 'Saturn' }

        allow(provider).to receive(:supported_options_is).and_return(current)

        expect { provider.send(:specified_options_is, should) }.to raise_error(/TimeZone/)
      end

      it 'returns a hash of all specified options and their current values' do
        current = { 'PageSize' => 'Letter', 'Duplex' => 'None' }
        should = { 'PageSize' => 'A4' }
        expected = { 'PageSize' => 'Letter' }

        allow(provider).to receive(:supported_options_is).and_return(current)

        expect(provider.send(:specified_options_is, should)).to eq(expected)
      end
    end

    describe '#supported_options_is' do
      it 'merges native and vendor options' do
        native = { 'printer-error-policy' => 'retry-job' }
        vendor = { 'Duplex' => 'None' }

        allow(provider).to receive(:native_options_is).and_return(native)
        allow(provider).to receive(:vendor_options_is).and_return(vendor)

        expect(provider.send(:supported_options_is)).to eq('Duplex' => 'None', 'printer-error-policy' => 'retry-job')
      end
    end

    describe '#native_options_is' do
      it 'returns a hash' do
        allow(provider).to receive(:query).and_return('dummy')

        expect(provider.send(:native_options_is)).to be_a Hash
      end
    end

    describe '#query_native_option' do
      context "'auth-info-required'" do
        it "upon empty query result returns 'none'" do
          allow(provider).to receive(:query).with('auth-info-required').and_return('')

          expect(provider.send(:query_native_option, 'auth-info-required')).to eq('none')
        end

        it 'returns nonempty query results unmodified' do
          allow(provider).to receive(:query).with('auth-info-required').and_return('username,password')

          expect(provider.send(:query_native_option, 'auth-info-required')).to eq('username,password')
        end
      end

      context 'using any other option' do
        it 'returns nonempty query results unmodified' do
          allow(provider).to receive(:query).with('printer-error-policy').and_return('abort-job')

          expect(provider.send(:query_native_option, 'printer-error-policy')).to eq('abort-job')
        end
      end
    end

    describe '#vendor_options_is' do
      context 'for a raw queue' do
        it 'should return an empty hash' do
          input = "lpoptions: Unable to get PPD file for Rawe: Not Found\n"

          allow(provider).to receive(:lpoptions).with('-E', '-p', 'Office', '-l').and_return(input)

          expect(provider.send(:vendor_options_is)).to eq({})
        end
      end

      context 'for a queue using a PPD file' do
        it 'should return a hash of vendor options and their current values' do
          input = <<~INPUT
            PageSize/Who: Custom.WIDTHxHEIGHT Letter Legal Executive FanFoldGermanLegal *A4 A5 A6 Env10 EnvMonarch EnvDL EnvC5
            MediaType/cares: *PLAIN THIN THICK THICKERPAPER2 BOND ENV ENVTHICK ENVTHIN RECYCLED
            InputSlot/about: MANUAL *TRAY1
            Duplex/this: DuplexTumble DuplexNoTumble *None
          INPUT

          expected = {
            'PageSize' => 'A4',
            'MediaType' => 'PLAIN',
            'InputSlot' => 'TRAY1',
            'Duplex' => 'None'
          }

          allow(provider).to receive(:lpoptions).with('-E', '-p', 'Office', '-l').and_return(input)

          expect(provider.send(:vendor_options_is)).to eq(expected)
        end
      end
    end

    describe '#users_is' do
      context 'when no policy is in place' do
        it "returns 'all'" do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('')

          expect(provider.send(:users_is)).to eq(%w[all])
        end
      end

      context 'when there are users on an allow policy' do
        it 'returns a sorted array without duplicates' do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('nina,@council,nina,lumbergh')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('')

          expect(provider.send(:users_is)).to eq(%w[@council lumbergh nina])
        end
      end

      context 'when there are users on an deny policy' do
        it 'returns a sorted array without duplicates' do
          allow(provider).to receive(:query).with('requesting-user-name-allowed').and_return('')
          allow(provider).to receive(:query).with('requesting-user-name-denied').and_return('nina,@council,nina,lumbergh')

          expect(provider.send(:users_is)).to eq(%w[@council lumbergh nina])
        end
      end
    end

    describe '#users_should' do
      context 'when the `access` property was NOT specified' do
        it 'returns an empty array' do
          allow(resource).to receive(:should).with(:access).and_return(nil)

          expect(provider.send(:users_should)).to eq([])
        end
      end

      context 'when the `access` property was specified' do
        it 'returns the value for `users`' do
          allow(resource).to receive(:should).with(:access).and_return('policy' => 'allow', 'users' => ['@council', 'lumbergh', 'nina'])

          expect(provider.send(:users_should)).to eq(['@council', 'lumbergh', 'nina'])
        end
      end
    end
  end
end
