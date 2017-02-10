require 'open3'

module PuppetX
  module Cups
    # Namespace encapsulating helper functions
    # to query the CUPS server
    module Server
      def self.query(request, resource = '/')
        output = ipptool(resource, request)
        output.split("\n")[1..-1]
      rescue
        raise("Failed to query resource 'ipp://localhost#{resource}' with request:\n#{request}")
      end

      def self.ipptool(resource, request)
        output, _, process = Open3.capture3("ipptool -c ipp://localhost#{resource} /dev/stdin", stdin_data: request)
        raise if process.exitstatus.nonzero?
        output
      end
    end
  end
end
