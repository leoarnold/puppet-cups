require 'open3'

module PuppetX
  module Cups
    # Namespace encapsulating helper functions
    # to query the CUPS server
    module Ipp
      def self.query(request, resource = '/')
        query = Query.new(resource, request)
        stdout = ipptool(query)
        Response.new(stdout)
      end

      def self.ipptool(query)
        command = "ipptool -c #{query.uri} /dev/stdin"

        stdout, stderr, process_status = Open3.capture3(command, stdin_data: query.request)

        raise Error.new(query, stdout, stderr) if process_status.exitstatus.nonzero? || stdout.empty?

        stdout
      end

      # A value object to encapsulate all query data
      class Query
        attr_reader :request, :uri

        def initialize(resource, request)
          @request = request
          @uri = "ipp://localhost#{resource}"
        end
      end

      # A value object containing a query to the CUPS server
      # and all of its metadata.
      class Response
        attr_reader :stdout

        def initialize(stdout)
          @stdout = stdout
        end

        def stdout_lines
          @stdout.split("\n")
        end

        def rows
          stdout_lines[1..-1]
        end

        def first_row
          rows.is_a?(Array) ? rows[0] : nil
        end
      end

      # A custom error class for easier qualification of errors
      class Error < StandardError
        def initialize(query, stdout, stderr)
          message = if stderr == "successful-ok\n"
                      # Related issue: https://github.com/leoarnold/puppet-cups/issues/6
                      "IPP query to '#{query.uri}' failed. Please check whether the corresponding PPD file conforms to RFC 2911."
                    else
                      "IPP query to '#{query.uri}' failed.\n" \
                      "Request:\n#{query.request}\n" \
                      "STDOUT:\n#{stdout}\n" \
                      "STDERR:\n#{stderr}"
                    end

          super(message)
        end
      end
    end
  end
end
