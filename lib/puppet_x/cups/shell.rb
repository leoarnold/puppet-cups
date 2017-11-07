require 'open3'

module PuppetX
  module Cups
    # Namespace encapsulating helpers for command line executions
    #
    # @author Leo Arnold
    # @since 2.0.0
    module Shell
      # A convenience wrapper for shell invocations of `ipptool`
      #
      # @see https://www.cups.org/doc/man-ipptool.html
      #
      # @author Leo Arnold
      # @since 2.0.0
      #
      # @param switch [String] A valid `ipptool` command line switch
      # @param resource [String] The resource part of the URL which should be queried
      # @param request [String] A valid IPP request
      #
      # @return [ShellOut] The result of executing `ipptool`
      def self.ipptool(switch, resource, request)
        ShellOut.new("ipptool #{switch} ipp://localhost#{resource} /dev/stdin", request)
      end

      # Wrapper class for command line executions
      #
      # @author Leo Arnold
      # @since 2.0.0
      #
      # @attr_reader command [String] The shell command which was executed
      # @attr_reader stdin [String] The data piped to the command via STDIN
      # @attr_reader stdout [String] The output of the shell command on STDOUT
      # @attr_reader stderr [String] The output of the shell command on STDERR
      # @attr_reader exitcode [Integer] The exit code of the shell execution
      class ShellOut
        attr_reader :command, :stdin, :stdout, :stderr, :exitcode

        # Executes the `command` while piping `stdin` into STDIN
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @attr_reader command [String] The shell command to be executed
        # @attr_reader stdin [String] The data to be piped into STDIN
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
