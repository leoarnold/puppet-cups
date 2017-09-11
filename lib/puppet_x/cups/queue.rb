require 'erb'

require_relative 'ipp'

module PuppetX
  module Cups
    module Queue
      def self.attribute(queue, property)
        attribute = Attribute.new(queue, property)

        attribute.value
      end

      # Namespace encapsulating helper functions
      # to query the CUPS server for print queue attributes
      class Attribute
        def initialize(queue, name)
          @queue = queue
          @name = name
        end

        def value
          query = PuppetX::Cups::Ipp.query(resource, request)

          query.results.empty? ? '' : query.results.first
        end

        private

        def resource
          '/printers/' + ERB::Util.url_encode(@queue)
        end

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
