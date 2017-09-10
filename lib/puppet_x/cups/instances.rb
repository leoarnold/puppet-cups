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
          ClassMembers.to_h.keys
        end
      end

      # A hash with the names of all classes (as keys) and their members (as array value).
      module ClassMembers
        def self.to_h
          classmembers = {}

          query = PuppetX::Cups::Ipp::QueryC.new('/', request)
          query.results.each do |line|
            classname, members = line.split(',', 2)
            classmembers[classname] = members.gsub(/\A"|"\Z/, '').split(',') if members
          end

          classmembers
        end

        def self.request
          <<-REQUEST
            {
              OPERATION CUPS-Get-Classes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              DISPLAY printer-name
              DISPLAY member-names
            }
          REQUEST
        end
      end

      # An array of the names of all installed print queues (*excluding* classes).
      module Printers
        def self.to_a
          Queues.to_a - Classes.to_a
        end
      end

      # An array of the names of all installed print queues (*including* classes).
      module Queues
        def self.to_a
          query = PuppetX::Cups::Ipp.query('/', request)

          query.results
        end

        def self.request
          <<-REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              DISPLAY printer-name
            }
          REQUEST
        end
      end
    end
  end
end
