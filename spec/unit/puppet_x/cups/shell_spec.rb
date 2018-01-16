# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/cups/shell'

RSpec.describe PuppetX::Cups::Shell do
  describe '##ipptool' do
    it 'shells out the correct command line' do
      expect(PuppetX::Cups::Shell::ShellOut).to receive(:new)
        .with('ipptool -ctv ipp://localhost/printers/Office /dev/stdin', '{ [Ipp] }')

      described_class.ipptool('-ctv', '/printers/Office', '{ [Ipp] }')
    end
  end
end

RSpec.describe PuppetX::Cups::Shell::ShellOut do
  describe '#new' do
    it 'encapsulates stdin, stdout, stderr, exitcode and the given command' do
      command = 'some command'
      stdin = 'mock stdin'

      stdout = 'mock stdout'
      stderr = 'mock stderr'
      exitcode = 0

      mock_ps = double(Process::Status)
      allow(mock_ps).to receive(:exitstatus).and_return(exitcode)
      allow(Open3).to receive(:capture3).with(command, stdin_data: stdin).and_return([stdout, stderr, mock_ps])

      shellout = described_class.new(command, stdin)

      expect(shellout.command).to eq command
      expect(shellout.stdin).to eq stdin
      expect(shellout.stdout).to eq stdout
      expect(shellout.stderr).to eq stderr
      expect(shellout.exitcode).to eq exitcode
    end
  end
end
