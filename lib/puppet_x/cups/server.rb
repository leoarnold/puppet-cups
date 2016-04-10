# encoding: UTF-8
require 'open3'

module PuppetX
  module Cups
    module Server
      # The IppResult class encapsules the use of the `ipptool` comand line utility.
      # It provides helper methods and basic error handling.
      class IppResult
        def initialize(request, resource = '/')
          @output, @error, process = query(resource, request)
          raise('Unexpected response from CUPS server.') if process.exitstatus != 0
        end

        def lines
          @output.split("\n")[1..-1]
        end

        private

        def query(resource, request)
          Open3.capture3("ipptool -c ipp://localhost#{resource} /dev/stdin", stdin_data: request)
        rescue
          raise('Error using `ipptool` (CUPS 1.5 and later) command line tool.')
        end
      end
    end
  end
end
