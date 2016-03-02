require 'erb'
require 'open3'

module Cups
  # Namespace for modules related to generation of Puppet Facts
  #
  # The design of this module is based on the ideas of R. Tyler Croy:
  # http://unethicalblogger.com/2014/03/01/testing-custom-facts-with-rspec.html
  module Facts
    def self.add_facts
      Facter.add(:cups_classes) { setcode { Cups::Facts::Classes.fact } }
      Facter.add(:cups_classmembers) { setcode { Cups::Facts::ClassMembers.fact } }
      Facter.add(:cups_printers) { setcode { Cups::Facts::Printers.fact } }
      Facter.add(:cups_queues) { setcode { Cups::Facts::Queues.fact } }
    end

    # `cups_classes`: An array of the names of all installed classes.
    module Classes
      def self.fact
        Cups::Facts::ClassMembers.fact.keys
      rescue
        []
      end
    end

    # `cups_classmembers`: A hash with the names of all classes (as keys) and their members (as array value).
    module ClassMembers
      def self.fact
        result = Cups::Server::IppResult.new(request)
        classmembers = {}
        result.lines.each do |line|
          classname, members = line.split(',', 2)
          classmembers[classname] = members.gsub(/\A"|"\Z/, '').split(',') if members
        end
        classmembers
      rescue
        {}
      end

      def self.request
        '{
          OPERATION CUPS-Get-Classes
          GROUP operation
          ATTR charset attributes-charset utf-8
          ATTR language attributes-natural-language en
          STATUS successful-ok
          DISPLAY printer-name
          DISPLAY member-names
        }'
      end
    end

    # `cups_printers`: An array of the names of all installed print queues (*excluding* classes).
    module Printers
      def self.fact
        Cups::Facts::Queues.fact - Cups::Facts::Classes.fact
      rescue
        []
      end
    end

    # `cups_queues`: An array of the names of all installed print queues (*including* classes).
    module Queues
      def self.fact
        result = Cups::Server::IppResult.new(request)
        queues = result.lines
        queues
      rescue
        []
      end

      def self.request
        '{
          OPERATION CUPS-Get-Printers
          GROUP operation
          ATTR charset attributes-charset utf-8
          ATTR language attributes-natural-language en
          STATUS successful-ok
          DISPLAY printer-name
        }'
      end
    end
  end

  module Server
    # The IppResult class encapsules the use of the `ipptool` comand line utility.
    # It provides helper methods and basic error handling.
    class IppResult
      def initialize(request, resource = '/')
        @output, @error, process = query(resource, request)
        raise('Unexpected response from CUPS server.') if process.exitstatus != 0
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
