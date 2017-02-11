require 'erb'

require_relative 'ipp'

module PuppetX
  module Cups
    module Queue
      # Namespace encapsulating helper functions
      # to query the CUPS server for print queue attributes
      module Attribute
        def self.query(queue, property)
          resource = '/printers/' + ERB::Util.url_encode(queue)
          response = PuppetX::Cups::Ipp.query(request(property), resource)

          response.first_row
        end

        def self.request(property)
          "{
            OPERATION Get-Printer-Attributes
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
end
