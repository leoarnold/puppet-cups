require 'erb'
require 'open3'

module Cups
  module Server
    # The IppResult class encapsules the use of the `ipptool` comand line utility.
    # It provides helper methods and basic error handling.
    class IppResult
      def initialize(request, resource = '/')
        @output, @error, process = query(resource, request)
        fail('Unexpected response from CUPS server.') if process.exitstatus != 0
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

  module Queue
    # Namespace encapsulating helper functions
    # to query the CUPS server for print queue attributes
    module Attribute
      def self.query(queue, property)
        resource = '/printers/' + ERB::Util.url_encode(queue)
        result = Cups::Server::IppResult.new(request(property), resource)
        result.lines[0]
      end

      def self.request(property)
        "{
          OPERATION get-printer-attributes
          GROUP operation
          ATTR charset attributes-charset utf-8
          ATTR language attributes-natural-language en
          ATTR uri printer-uri $uri
          STATUS successful-ok
          DISPLAY #{property}
        }"
      end
    end
  end
end
