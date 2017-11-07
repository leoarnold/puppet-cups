require_relative 'shell'

# The Puppet Extensions Module
module PuppetX
  # Namespace encapsulating all Puppet extension from the `leoarnold-cups` module
  #
  # @author Leo Arnold
  # @since 1.0.0
  module Cups
    # Namespace encapsulating helpers to query the CUPS server
    #
    # @author Leo Arnold
    # @since 2.0.0
    module Ipp
      # A resilient method to query the CUPS server
      #
      # Attemps to retrieve the value from the CSV table returned by `ipptool -c`.
      # This fails on some systems (e.g. Ubuntu 16.10) or when the queue uses
      # a slightly malformed PPD file. In case of failure, the method attemps
      # to parse the value from the output of `ipptool -t`.
      #
      # @see https://www.cups.org/doc/man-ipptool.html
      #
      # @author Leo Arnold
      # @since 2.0.0
      #
      # @param resource [String] The resource part of the URL which should be queried
      # @param request [String] A valid IPP request
      #
      # @return [String] The requested value
      def self.query(resource, request)
        QueryC.new(resource, request)
      rescue QueryError => e
        Puppet.debug(e.message) if defined? Puppet
        QueryT.new(resource, request)
      end

      # @abstract
      #
      # The abstract superclass for IPP queries using the `ipptool` command line utility
      #
      # @author Leo Arnold
      # @since 2.0.0
      class Query
        # Executes the query
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @param resource [String] The resource part of the URL which should be queried
        # @param request [String] A valid IPP request
        #
        # @raise [QueryError] Provides detailed debug info in case of failure
        def initialize(resource, request)
          @shellout = PuppetX::Cups::Shell.ipptool(switch, resource, request)

          raise! if failed?
        end

        private

        # @private
        #
        # The default `ipptool` command line switch
        #
        # @see https://www.cups.org/doc/man-ipptool.html
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [String] A valid `ipptool` command line switch
        def switch
          ''
        end

        # @private
        #
        # The default mechanism to determine whether the `ipptool` should be regarded as failure
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [Boolean] Did the command execution yield a nonzero exit code?
        def failed?
          @shellout.exitcode.nonzero?
        end

        # @private
        #
        # Converts the encapsulated {Shell::ShellOut} into a {QueryError}
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [QueryError] Provides detailed debug info in case of failure
        #
        # @raise [QueryError] Provides detailed debug info in case of failure
        def raise!
          raise QueryError, @shellout
        end
      end

      # Wrapper class for queries using `ipptool -c`
      #
      # @see https://www.cups.org/doc/man-ipptool.html
      #
      # @author Leo Arnold
      # @since 2.0.0
      class QueryC < Query
        # Returns the rows of the CSV table without the header
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [Array] The rows of the CSV table without the header
        def results
          lines = @shellout.stdout.split("\n")

          lines[1..-1]
        end

        private

        # Make `ipptool` return a CSV table
        #
        # @see https://www.cups.org/doc/man-ipptool.html
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [String] `-c`
        def switch
          '-c'
        end
      end

      # Wrapper class for queries using `ipptool -t`
      class QueryT < Query
        # Tries to parse the requested value from the output of `ipptool -t`.
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [Array] All values matching the requested attribute
        def results
          result = /\bDISPLAY\s+(?<attribute>\S+)/i.match(@shellout.stdin)

          raise! if result[:attribute].nil?

          @shellout.stdout.scan(/#{result[:attribute]} \([^)]+\) = (.*)$/).flatten
        end

        private

        # Make `ipptool` return the test report
        #
        # @see https://www.cups.org/doc/man-ipptool.html
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [String] `-t`
        def switch
          '-t'
        end

        # @private
        #
        # Determines whether the execution of `ipptool -t` should be regarded as failure.
        #
        # The command `ipptool -t` yields a nonzero exit code when the IPP response was malformed.
        # The output of the command contains `status-code = successful-ok`
        # then the requested values were retrieved nevertheless.
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [Boolean] Was the output of the command really useless?
        def failed?
          @shellout.exitcode.nonzero? && !@shellout.stdout.include?('status-code = successful-ok')
        end
      end

      # A custom error class yielding detailed debug information
      #
      # @author Leo Arnold
      # @since 2.0.0
      class QueryError < StandardError
        # A new instance of QueryError.
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @param shellout [ShellOut] The command execution which did not yield the desired results
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
