require 'open3'

module PuppetX
  module Cups
    module Shell
      def self.ipptool(switch, resource, request)
        ShellOut.new("ipptool #{switch} ipp://localhost#{resource} /dev/stdin", request)
      end

      class ShellOut
        attr_reader :command, :stdin, :stdout, :stderr, :exitcode

        def initialize(command, stdin)
          @command = command
          @stdin = stdin

          @stdout, @stderr, process_status = Open3.capture3(command, stdin_data: stdin)

          @exitcode = process_status.exitstatus
        end
      end
    end
  end
end
