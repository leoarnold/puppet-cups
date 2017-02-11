require_relative 'ipp'

module PuppetX
  module Cups
    # Namespace for modules related to querying the CUPS server for available queue instances
    #
    # The design of this module is based on the ideas of R. Tyler Croy:
    # http://unethicalblogger.com/2014/03/01/testing-custom-facts-with-rspec.html
    module Instances
      # An array of the names of all installed classes.
      module Classes
        def self.to_a
          PuppetX::Cups::Instances::ClassMembers.to_h.keys
        end
      end

      # A hash with the names of all classes (as keys) and their members (as array value).
      module ClassMembers
        def self.to_h
          classmembers = {}

          response = PuppetX::Cups::Ipp.query(request)
          response.rows.each do |line|
            classname, members = line.split(',', 2)
            classmembers[classname] = members.gsub(/\A"|"\Z/, '').split(',') if members
          end

          classmembers
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

      # An array of the names of all installed print queues (*excluding* classes).
      module Printers
        def self.to_a
          PuppetX::Cups::Instances::Queues.to_a - PuppetX::Cups::Instances::Classes.to_a
        end
      end

      # An array of the names of all installed print queues (*including* classes).
      module Queues
        def self.to_a
          response = PuppetX::Cups::Ipp.query(request)

          response.rows
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
  end
end
