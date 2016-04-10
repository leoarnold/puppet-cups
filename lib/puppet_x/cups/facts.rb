# encoding: UTF-8
require_relative 'server'

module PuppetX
  module Cups
    # Namespace for modules related to generation of Puppet Facts
    #
    # The design of this module is based on the ideas of R. Tyler Croy:
    # http://unethicalblogger.com/2014/03/01/testing-custom-facts-with-rspec.html
    module Facts
      def self.add_facts
        Facter.add(:cups_classes) { setcode { PuppetX::Cups::Facts::Classes.fact } }
        Facter.add(:cups_classmembers) { setcode { PuppetX::Cups::Facts::ClassMembers.fact } }
        Facter.add(:cups_printers) { setcode { PuppetX::Cups::Facts::Printers.fact } }
        Facter.add(:cups_queues) { setcode { PuppetX::Cups::Facts::Queues.fact } }
      end

      # `cups_classes`: An array of the names of all installed classes.
      module Classes
        def self.fact
          PuppetX::Cups::Facts::ClassMembers.fact.keys
        rescue
          []
        end
      end

      # `cups_classmembers`: A hash with the names of all classes (as keys) and their members (as array value).
      module ClassMembers
        def self.fact
          result = PuppetX::Cups::Server::IppResult.new(request)
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
          PuppetX::Cups::Facts::Queues.fact - Cups::Facts::Classes.fact
        rescue
          []
        end
      end

      # `cups_queues`: An array of the names of all installed print queues (*including* classes).
      module Queues
        def self.fact
          result = PuppetX::Cups::Server::IppResult.new(request)
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
  end
end
