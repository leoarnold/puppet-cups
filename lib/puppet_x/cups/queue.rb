# encoding: UTF-8
require 'erb'

require_relative 'server'

module PuppetX
  module Cups
    module Queue
      # Namespace encapsulating helper functions
      # to query the CUPS server for print queue attributes
      module Attribute
        def self.query(queue, property)
          resource = '/printers/' + ERB::Util.url_encode(queue)
          result = PuppetX::Cups::Server::IppResult.new(request(property), resource)
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
end
