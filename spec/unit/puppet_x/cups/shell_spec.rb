# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/shell'

RSpec.describe PuppetX::Cups::Shell do
  describe '##ipptool' do
    it 'shells out the correct command line' do
      allow(PuppetX::Cups::Shell::ShellOut).to receive(:new)

      described_class.ipptool('-ctv', '/printers/Office', '{ [Ipp] }')

      expect(PuppetX::Cups::Shell::ShellOut).to have_received(:new).with('ipptool -ctv ipp://localhost/printers/Office /dev/stdin', '{ [Ipp] }')
    end
  end

  describe 'ShellOut' do
    let(:described_class) { PuppetX::Cups::Shell::ShellOut }

    describe '#new' do
      let(:command) { 'some command' }
      let(:stdin) { 'mock stdin' }

      let(:shellout) { described_class.new(command, stdin) }

      let(:stdout) { 'mock stdout' }
      let(:stderr) { 'mock stderr' }
      let(:exitcode) { 0 }

      let(:mock_ps) { instance_double(Process::Status) }

      before do
        allow(mock_ps).to receive(:exitstatus).and_return(exitcode)
        allow(Open3).to receive(:capture3).with(command, stdin_data: stdin).and_return([stdout, stderr, mock_ps])
      end

      it 'encapsulates the given command' do
        expect(shellout.command).to eq command
      end

      it 'encapsulates stdin' do
        expect(shellout.stdin).to eq stdin
      end

      it 'encapsulates stdout' do
        expect(shellout.stdout).to eq stdout
      end

      it 'encapsulates stderr' do
        expect(shellout.stderr).to eq stderr
      end

      it 'encapsulates exitcode' do
        expect(shellout.exitcode).to eq exitcode
      end
    end
  end
end
