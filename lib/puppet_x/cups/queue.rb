require 'erb'

require_relative 'ipp'

module PuppetX
  module Cups
    # Namespace encapsulating helpers to query the CUPS server for print queue attributes
    #
    # @author Leo Arnold
    # @since 1.0.0
    module Queue
      # Retrieves the value of a queue attribute
      #
      # @author Leo Arnold
      # @since 2.0.0
      #
      # @param queue [String] The name of a queue
      # @param property [String] The name of a queue attribute
      #
      # @return [String] The value of the requested queue attribute
      def self.attribute(queue, property)
        attribute = Attribute.new(queue, property)

        attribute.value
      end

      # A wrapper class for queue attribute queries
      #
      # @author Leo Arnold
      # @since 2.0.0
      class Attribute
        # Returns a new instance of Attribute
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @param queue [String] The name of the queue
        # @param name [String] The name of the attribute
        def initialize(queue, name)
          @queue = queue
          @name = name
        end

        # Executes the query and returns the attribute value
        # without surrounding quotes, or an empty string
        # if the query did not return a value
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [String] The attribute value (if any) without surrounding quotes, or an empty string
        def value
          query = PuppetX::Cups::Ipp.query(resource, request)

          answer = query.results.empty? ? '' : query.results.first

          answer.gsub(/\A"|"\Z/, '')
        end

        private

        # @private
        #
        # Encodes the queue name and returns the resource to query
        #
        # @author Leo Arnold
        # @since 2.0.0
        #
        # @return [String] The resource to query
        def resource
          '/printers/' + ERB::Util.url_encode(@queue)
        end

        # @private
        #
        # The IPP request required to retrieve the value of the requested attribute
        #
        # @see https://www.cups.org/doc/spec-ipp.html
        #
        # @author Leo Arnold
        # @since 1.0.0
        #
        # @return [String] IPP `Get-Printer-Attributes` request to display the value of the requested attribute
        def request
          <<-REQUEST
            {
              OPERATION Get-Printer-Attributes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              ATTR uri printer-uri $uri
              STATUS successful-ok
              DISPLAY #{@name}
            }
          REQUEST
        end
      end
    end
  end
end
