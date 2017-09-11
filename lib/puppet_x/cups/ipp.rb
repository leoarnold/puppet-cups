require_relative 'shell'

module PuppetX
  module Cups
    # Namespace encapsulating helpers
    # to query the CUPS server
    module Ipp
      def self.query(resource, request)
        QueryC.new(resource, request)
      rescue QueryError => e
        Puppet.debug(e.message) if defined? Puppet
        QueryT.new(resource, request)
      end

      # The abstract superclass for IPP Queries
      # using the `ipptool` command line utility
      class Query
        def initialize(resource, request)
          @shellout = PuppetX::Cups::Shell.ipptool(switch, resource, request)

          raise! if failed?
        end

        private

        def switch
          ''
        end

        def failed?
          @shellout.exitcode.nonzero?
        end

        def raise!
          raise QueryError, @shellout
        end
      end

      # Wrapper class for queries using `ipptool -c`
      class QueryC < Query
        def results
          lines = @shellout.stdout.split("\n")

          lines[1..-1]
        end

        private

        def switch
          '-c'
        end
      end

      # Wrapper class for queries using `ipptool -t`
      class QueryT < Query
        def results
          result = /\bDISPLAY\s+(?<attribute>\S+)/i.match(@shellout.stdin)

          raise! if result[:attribute].nil?

          @shellout.stdout.scan(/#{result[:attribute]} \([^)]+\) = (.*)$/).flatten
        end

        private

        def switch
          '-t'
        end

        def failed?
          @shellout.exitcode.nonzero? && !@shellout.stdout.include?('status-code = successful-ok')
        end
      end

      # A custom error class for easier qualification of errors
      class QueryError < StandardError
        def initialize(shellout)
          message = "IPP query '#{shellout.command}' failed.\n" \
                    "EXITCODE: #{shellout.exitcode}\n" \
                    "STDIN:\n#{shellout.stdin}\n" \
                    "STDOUT:\n#{shellout.stdout}\n" \
                    "STDERR:\n#{shellout.stderr}"

          super(message)
        end
      end
    end
  end
end
