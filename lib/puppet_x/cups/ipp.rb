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
        command = "ipptool -c '#{query.uri}' /dev/stdin"

        stdout, stderr, process_status = Open3.capture3(command, stdin_data: query.request)

        if process_status.exitstatus.zero?
          raise Error.new(query, stdout, stderr) if stdout.empty?
        else
          raise Error.new(query, stdout, stderr) unless stderr == "No destinations added.\n"
        end

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
        def initialize(stdout)
          @stdout = stdout
        end

        def to_a
          lines.length > 1 ? lines[1..-1] : []
        end

        def to_s
          to_a.empty? ? nil : to_a.join(',')
        end

        private

        def lines
          answer = []

          @stdout.each_line do |line|
            answer << line.delete("\n")
          end

          answer
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
