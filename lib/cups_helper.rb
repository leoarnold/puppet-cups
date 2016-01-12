require 'open3'

module Cups
  module Server
    # The IppResult class encapsules the use of the `ipptool` comand line utility.
    # It provides helper methods and basic error handling.
    class IppResult
      def initialize(request)
        @output, @error, process = query(request)
        fail('Unexpected response from CUPS server.') if process.exitstatus != 0
      end

      def lines
        answer = @output.split("\n")
        answer.delete_at(0)
        answer
      end

      private

      def query(request)
        Open3.capture3('ipptool -c ipp://localhost/ /dev/stdin', stdin_data: request)
      rescue
        raise('Error using `ipptool` (CUPS 1.5 and later) command line tool.')
      end
    end
  end
end
